/*
 * Copyright (C) 2019 - All Rights Reserved
 *
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 */
package com.softvision.spring.boot.admin;

import de.codecentric.boot.admin.server.config.EnableAdminServer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@EnableAdminServer
@SpringBootApplication
public class SVSpringBootAdminApplication {
    private static final Logger logger = LoggerFactory.getLogger(SVSpringBootAdminApplication.class);

    public static void main(String[] args) {
//        SpringApplication springApplication = new SpringApplication(SVSpringBootAdminApplication.class);
//
//
//        springApplication.run(args);

        SpringApplication.run(SVSpringBootAdminApplication.class, args);
    }
}
