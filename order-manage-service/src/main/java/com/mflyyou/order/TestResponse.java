package com.mflyyou.order;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Map;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TestResponse implements Serializable {

    private static final long serialVersionUID = -2539917730465592841L;

    private String address;

    private Map gitInfo;
}
