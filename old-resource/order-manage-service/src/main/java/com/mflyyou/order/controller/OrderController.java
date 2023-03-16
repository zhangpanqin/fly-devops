package com.mflyyou.order.controller;

import com.mflyyou.order.TestResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.PropertiesFactoryBean;
import org.springframework.core.env.Environment;
import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.net.InetAddress;

@RestController
@RequestMapping("/orders")
public class OrderController {
    private static final String GIT_INFO_PATH = "git.properties";
    @Autowired
    Environment environment;

    @GetMapping("/test")
    public TestResponse test() throws IOException {
        InetAddress addr = InetAddress.getLocalHost();
        ClassPathResource classPathResource = new ClassPathResource(GIT_INFO_PATH);
        TestResponse.TestResponseBuilder builder = TestResponse.builder();
        if (classPathResource.exists()) {
            PropertiesFactoryBean propertiesFactoryBean = new PropertiesFactoryBean();
            propertiesFactoryBean.setLocation(classPathResource);
            propertiesFactoryBean.afterPropertiesSet();
            builder.gitInfo(propertiesFactoryBean.getObject());
        }

        return builder.address(addr.getHostAddress()).build();
    }

    @GetMapping("/test2")
    public String test2(@RequestParam(name = "name", defaultValue = "PATH") String name) {
        return environment.getProperty(name) + "&" + System.getProperty(name);
    }
}
