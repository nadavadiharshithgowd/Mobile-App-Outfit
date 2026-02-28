export interface ApiError {
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
}

export interface PaginatedResponse<T> {
  results: T[];
  count: number;
  next?: string;
  previous?: string;
}

export interface ApiResponse<T> {
  data: T;
  message?: string;
}
