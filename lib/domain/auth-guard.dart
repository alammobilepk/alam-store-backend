redirect: (context, state) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return '/login';
  return null;
}