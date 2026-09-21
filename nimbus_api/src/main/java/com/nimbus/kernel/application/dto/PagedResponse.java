package com.nimbus.kernel.application.dto;

import lombok.*;

import java.util.List;

/**
 * Response for paginated API endpoints.
 */
@Getter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class PagedResponse<T> {
    @Builder.Default
    private boolean success = true;
    private List<T> data;
    private PageMeta meta;
    private String timestamp;

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor
    public static class PageMeta {
        private int page;
        private int size;
        private long totalElements;
        private int totalPages;
    }
}