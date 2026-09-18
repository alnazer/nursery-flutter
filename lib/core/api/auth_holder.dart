/// يحمل الرمز واللغة الحاليين ليقرأهما ApiClient في كل طلب
/// بلا ربط دائري بين العميل وSessionCubit.
class AuthHolder {
  String? token;
  String locale = 'ar';
}
