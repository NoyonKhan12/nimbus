'use client';

import { useParams } from 'next/navigation';
import { ComplaintDetailView } from '@/components/DetailViews';

/** ComplaintDetail detail route. */
export default function ComplaintDetailDetailPage() {
  const params = useParams<{ id: string }>();
  return <ComplaintDetailView id={String(params.id)} />;
}
