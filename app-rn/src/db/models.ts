import { LatLng } from 'react-native-maps';

export interface TrackPoint {
  id?: number;
  activityId: string;
  lat: number;
  lng: number;
  elevation: number;
  timestamp: Date;
  speedMps: number;
  heartRate?: number | null;
  cadence?: number | null;
  accuracy: number;
  state: string;
}

export interface RunRecord {
  id: string;
  type: string;
  startedAt: Date;
  distanceM: number;
  durationMs: number;
  movingTimeMs: number;
  calories: number;
  elevationGainM: number;
  avgHeartRate: number;
  avgCadence: number;
  route: LatLng[];
  elevation: number[];
  pace: number[];
  times: Date[];
}

export const RunRecord_newId = (): string => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
    const r = (Math.random() * 16) | 0;
    const v = c === 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
};

export function runRecordFromTrackPoints(
  trackPoints: TrackPoint[],
  distanceM: number,
  durationMs: number,
  elevationGainM: number,
  calories: number,
  avgHeartRate?: number,
  avgCadence: number = 0,
  movingTimeMs: number = 0,
  type: string = 'Run'
): RunRecord {
  const route: LatLng[] = [];
  const elevation: number[] = [];
  const pace: number[] = [];
  const times: Date[] = [];
  let hrSum = 0;
  let hrCount = 0;

  for (const p of trackPoints) {
    route.push({ latitude: p.lat, longitude: p.lng });
    elevation.push(p.elevation);
    pace.push(p.speedMps > 0.3 ? 1000 / (p.speedMps * 60) : 0);
    times.push(p.timestamp);
    if (p.heartRate != null) {
      hrSum += p.heartRate;
      hrCount++;
    }
  }

  const startedAt = trackPoints.length > 0 ? trackPoints[0].timestamp : new Date();

  return {
    id: RunRecord_newId(),
    type,
    startedAt,
    distanceM,
    durationMs,
    movingTimeMs: movingTimeMs > 0 ? movingTimeMs : durationMs,
    calories,
    elevationGainM,
    avgHeartRate: avgHeartRate ?? (hrCount > 0 ? Math.round(hrSum / hrCount) : 0),
    avgCadence,
    route,
    elevation,
    pace,
    times,
  };
}