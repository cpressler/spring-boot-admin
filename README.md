#SV-SPRING-BOOT-ADMIN


## Adding login page

1)        <!--Add login page and logout feature-->
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-server-ui-login</artifactId>
            <version>${version.spring-boot-admin-ui-login}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <!--declare the admin server as a client, for self monitoring-->
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-starter-client</artifactId>
            <version>${version.spring-boot-admin-server}</version>
        </dependency>
2) application.yml configuration
        # controls the login credentials to the main admin page
    spring:    
        security:
            user:
                name: admin
                password: admin

 
## SSL Configuration
1) application.yml 
   Change port from 8988  to 9443
server:
  port: 9443
  ssl:
    key-alias: sv_wildcardcert
    key-password: changeit
    key-store: classpath:spring.keystore
    key-store-provider: SUN
    key-store-type: JKS
    protocols: TLSv1.2


## Web security

For Web Security and using AD/LDAP you need to create a WebSecurityConfig class to handle the authentication
By using the flag "ldap.enabled" we can control whether we want to enable using AD credentials to authenticate.
If the flag is false then no authentication is supplied and the user has access to the admin portal unrestricted.
This is useful for development SDLC

ldap.enabled: true   # turns on AD authentication. Login page is presented.
ldap.enabled: false   # turns off AD authentication. No login page is presented.

ldap.domain: softvision.com
ldap.url: ldaps://ldaphost.softvision.com:636

Notice the use of the folllowing class instance. This is needed  to work with Active Directory as opposed to LDAP/linux
ActiveDirectoryLdapAuthenticationProvider adProvider =
                    new ActiveDirectoryLdapAuthenticationProvider(domain,ldapUrl);

@Configuration
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Value("${ldap.url:ldap://lhqcrpadsdc01.softvision.com:389}")
    private String ldapUrl;
    @Value("${ldap.domain:softvision.com}")
    private String domain;
    @Value("${ldap.userDNPattern:}")
    private String ldapUserDNPattern;
    @Value("${ldap.enabled}")
    private String ldapEnabled;
    @Value("${ldap.baseDNPattern}")
    private String ldapBaseDnPattern;


    private final String adminContextPath;

    public WebSecurityConfig(AdminServerProperties adminServerProperties) {
        this.adminContextPath = adminServerProperties.getContextPath();
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        SavedRequestAwareAuthenticationSuccessHandler successHandler = new SavedRequestAwareAuthenticationSuccessHandler();
        successHandler.setTargetUrlParameter("redirectTo");
        successHandler.setDefaultTargetUrl(adminContextPath + "/");
        if(Boolean.parseBoolean(ldapEnabled)) { // if flag false then no security
            http.authorizeRequests()
                    .antMatchers(adminContextPath + "/assets/**").permitAll() // <1>
                    .antMatchers(adminContextPath + "/login").permitAll()
                    .anyRequest().authenticated() // <2>
                    .and()
                    .formLogin().loginPage(adminContextPath + "/login").successHandler(successHandler).and() // <3>
                    .logout().logoutUrl(adminContextPath + "/logout").and()
                    .httpBasic().and() // <4>
                    .csrf()
                    .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())  // <5>
                    .ignoringAntMatchers(
                            adminContextPath + "/instances",   // <6>
                            adminContextPath + "/actuator/**"  // <7>
                    );
        }
    }

    @Override
    public void configure(AuthenticationManagerBuilder auth) throws Exception {

        if(Boolean.parseBoolean(ldapEnabled)) {

            ActiveDirectoryLdapAuthenticationProvider adProvider =
                    new ActiveDirectoryLdapAuthenticationProvider(domain,ldapUrl);
            adProvider.setConvertSubErrorCodesToExceptions(true);
            adProvider.setUseAuthenticationRequestCredentials(true);

            // set pattern if it exists
            // The following example would authenticate a user if they were a member
            // of the ServiceAccounts group
            // (&(objectClass=user)(userPrincipalName={0})
            //   (memberof=CN=ServiceAccounts,OU=alfresco,DC=mycompany,DC=com))
            if (ldapUserDNPattern != null && ldapUserDNPattern.trim().length() > 0)
            {
                adProvider.setSearchFilter(ldapUserDNPattern);
            }
            auth.authenticationProvider(adProvider);

            // don't erase credentials if you plan to get them later
            // (e.g using them for another web service call)
            auth.eraseCredentials(false);
        }
    }

### Debugging AD
Put debugging breakpoint into this class to check
org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter


### selecting by AD groups


Searching for entry under DN '', base = 'dc=softvision,dc=com', filter = '(&(objectClass=user)(userPrincipalName={0}))'


(&(objectClass=user)(userPrincipalName={0}) (memberof=CN=int_developer,OU=org,OU=linuxgroups,OU=Groups,OU=UsersandComputers,DC=softvision,DC=com))


for 
ldap.domain: softvision.com
ldap.userDNPattern: 
Generates the following request
Searching for entry under DN '', base = 'dc=softvision,dc=com', filter = '(&(objectClass=user)(userPrincipalName={0}))'


### Setting up to filter by a group. 
This filters by making sure the user is in the developers group

ldap:
  enabled: true
  url: ldaps://ldaphost.softvision.com:636
  domain: softvision.com
  userDNPattern: (&(objectClass=user)(userPrincipalName={0}) (memberof=CN=developers,OU=Distribution Groups,OU=Groups,OU=UsersandComputers, DC=softvision,DC=com))

  
This filters by making sure the user is validated with password regardless of group
  
ldap:
  enabled: true
  url: ldaps://ldaphost.softvision.com:636
  domain: softvision.com
  userDNPattern: (&(objectClass=user)(userPrincipalName={0}))  # if not provided this is the default
 