import { createRequire } from 'module';
const require = createRequire(import.meta.url);

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ['images.unsplash.com', 'ui-avatars.com'],
  },
  env: {
    API_BASE_URL:
      process.env.NEXT_PUBLIC_API_BASE_URL ||
      process.env.API_BASE_URL ||
      'http://localhost:9090/api/v1',
    ADMIN_LOGIN_URL: process.env.ADMIN_LOGIN_URL || '/login',
  },
};

export default nextConfig;
