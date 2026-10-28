import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import '@/styles/globals.css';
import { ToastProvider } from '@/components/toast';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Nimbus Admin Panel',
  description: 'Admin panel for managing Nimbus ride-pooling platform',
  icons: {
    icon: [
      { url: '/favicon.ico' },
      { url: '/nimbus-favicon-16.png', sizes: '16x16', type: 'image/png' },
      { url: '/nimbus-favicon-32.png', sizes: '32x32', type: 'image/png' },
      { url: '/nimbus-favicon-64.png', sizes: '64x64', type: 'image/png' },
      { url: '/nimbus-favicon-128.png', sizes: '128x128', type: 'image/png' },
      { url: '/nimbus-favicon-256.png', sizes: '256x256', type: 'image/png' },
    ],
    apple: '/nimbus-favicon-256.png',
  },
};

/**
 * Root layout for the admin panel.
 */
export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <ToastProvider>{children}</ToastProvider>
      </body>
    </html>
  );
}
