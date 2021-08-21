package com.mflyyou.order.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

@RestController
@RequestMapping("/")
public class IndexController {
    private static final String GIT_INFO_PATH = "git.properties";

    @RequestMapping("")
    public String test() throws IOException {
        return "";
    }
}
