// ────────────────────────────────────────────────
// Paginated Response Types
// ────────────────────────────────────────────────

export interface PageMeta {
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
}

export interface PagedResponse<T> {
  success: boolean;
  data: T[];
  meta: PageMeta;
  timestamp: string;
}
