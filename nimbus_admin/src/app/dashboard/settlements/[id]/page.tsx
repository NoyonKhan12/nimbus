'use client';

import { useParams } from 'next/navigation';
import { SettlementDetailView } from '@/components/DetailViews';

/** SettlementDetail detail route. */
export default function SettlementDetailDetailPage() {
  const params = useParams<{ id: string }>();
  return <SettlementDetailView id={String(params.id)} />;
}
