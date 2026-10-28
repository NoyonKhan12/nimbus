'use client';

import { useParams } from 'next/navigation';
import { RideDetailView } from '@/components/DetailViews';

/** Ride detail route. */
export default function RideDetailPage() {
  const params = useParams<{ id: string }>();
  return <RideDetailView id={String(params.id)} />;
}
