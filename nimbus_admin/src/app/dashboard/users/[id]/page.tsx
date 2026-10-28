'use client';

import { useParams } from 'next/navigation';
import { UserDetailView } from '@/components/DetailViews';

/** Shared user detail route — also serves the Passengers list destinations. */
export default function UserDetailPage() {
  const params = useParams<{ id: string }>();
  return <UserDetailView id={String(params.id)} />;
}
