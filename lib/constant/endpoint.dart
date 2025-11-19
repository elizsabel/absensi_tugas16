class Endpoint {
  static const baseUrl = 'https://appabsensi.mobileprojp.com'; // SESUAIKAN
  static const register = '$baseUrl/api/register';
  static const trainings = '$baseUrl/api/trainings'; // SESUAIKAN DENGAN BACKEND
  static const trainingBatches = '$baseUrl/api/batches';
  static const login = '$baseUrl/api/login';
  static const checkIn = '$baseUrl/api/absen/check-in';
  static const checkOut = '$baseUrl/api/absen/check-out';
  static const izin = '$baseUrl/api/izin';
  static const statistik = '$baseUrl/api/absen/stats';
  static const history = '$baseUrl/api/absen/history';
  static const profile = '$baseUrl/api/profile';
  static const updateProfile = '$baseUrl/api/profile';
  static const deleteAbsen = '$baseUrl/api/absen';
}
