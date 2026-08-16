enum TrackVersion {
  deviceLive('device_live'),
  kalmanEkf('kalman_ekf'),
  osrmMatched('osrm_matched');

  final String id;
  const TrackVersion(this.id);
}
