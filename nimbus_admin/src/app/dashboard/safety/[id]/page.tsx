'use client';

import { useParams } from 'next/navigation';
import { SafetyDetailView } from '@/components/DetailViews';

/** SafetyDetail detail route. */
export default function SafetyDetailDetailPage() {
  const params = useParams<{ id: string }>();
  return <SafetyDetailView id={String(params.id)} />;
}
