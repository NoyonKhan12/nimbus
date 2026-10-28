'use client';

import { useParams } from 'next/navigation';
import { DriverDetailView } from '@/components/DetailViews';

/** Driver detail route. */
export default function DriverDetailPage() {
  const params = useParams<{ id: string }>();
  return <DriverDetailView id={String(params.id)} />;
}
