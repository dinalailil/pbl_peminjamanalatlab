String halamanByRole(String role) {
  if (role == "admin") {
    return "admin_home";
  }
  return "user_home";
}
