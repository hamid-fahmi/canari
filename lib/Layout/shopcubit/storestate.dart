abstract class ShopStates {}

class ShopIntiaialStates extends ShopStates {}

class GetResturantDataLoadingState extends ShopStates {}

class GetResturantDataSucessfulState extends ShopStates {}

class GetResturantDataErrorState extends ShopStates {
  String error;
  GetResturantDataErrorState(this.error);
}
class GetSlidersLoadingState extends ShopStates {}

class GetSlidersSucessfulState extends ShopStates {}

class GetSlidersErrorState extends ShopStates {
  String error;
  GetSlidersErrorState(this.error);
}
class GetResturantPageDataLoadingState extends ShopStates {}

class GetResturantPageDataSucessfulState extends ShopStates {}

class GetResturantPageDataErrorState extends ShopStates {
  String error;
  GetResturantPageDataErrorState(this.error);
}

class GetCategoryDataLoadingState extends ShopStates {}

class GetCategoryDataSucessfulState extends ShopStates {}

class GetCategoryDataErrorState extends ShopStates {
  String error;
  GetCategoryDataErrorState(this.error);
}

class GetSearchLoadingState extends ShopStates {}

class GetSearchSucessfulState extends ShopStates {}

class GetSearchErrorState extends ShopStates {
  String error;
  GetSearchErrorState(this.error);
}
class AddtoCartSucessfulState extends ShopStates {
  final totalprice;

  AddtoCartSucessfulState(this.totalprice);
}
class RemovetoCartSucessfulState extends ShopStates {}
class minusSucessfulState extends ShopStates {}
class pluseSucessfulState extends ShopStates {}

class CheckoutLoadingState extends ShopStates {}

class CheckoutSucessfulState extends ShopStates {}

class CheckoutErrorState extends ShopStates {
  String error;
  CheckoutErrorState(this.error);
}
class RegisterLoadingStates extends ShopStates {}

class RegisterSucessfulState extends ShopStates {
  final data;

  RegisterSucessfulState(this.data);
}

class RegisterErrorState extends ShopStates {
  String error;
  RegisterErrorState(this.error);
}

class LoginLoadingStates extends ShopStates {}

class LoginSucessfulState extends ShopStates {
  final data;
  LoginSucessfulState(this.data);
}

class LoginErrorState extends ShopStates {
  String error;
  LoginErrorState(this.error);
}

class MyorderLoadingState extends ShopStates {}

class MyorderSucessfulState extends ShopStates {
  final Map<String, dynamic> order;

  MyorderSucessfulState(this.order);
}

class MyorderErrorState extends ShopStates {
  String error;
  MyorderErrorState(this.error);
}
class MyordersLoadingState extends ShopStates {}

class MyordersSucessfulState extends ShopStates {
  final Map<String, dynamic> order;

  MyordersSucessfulState(this.order);
}

class MyordersErrorState extends ShopStates {
  String error;
  MyordersErrorState(this.error);
}

class GetFilterDataLoadingState extends ShopStates {}

class GetFilterDataSucessfulState extends ShopStates {
  final List filters;

  GetFilterDataSucessfulState(this.filters);
}

class GetFilterDataErrorState extends ShopStates {
  String error;
  GetFilterDataErrorState(this.error);
}

class ChangevalueState extends ShopStates {}

class UpdateProfileLoadingState extends ShopStates {}

class UpdateProfileSucessfulState extends ShopStates {}

class UpdateProfileErrorState extends ShopStates {
  String error;
  UpdateProfileErrorState(this.error);
}

class GetConfigLoadingState extends ShopStates {}

class GetConfigSucessfulState extends ShopStates {}

class GetConfigErrorState extends ShopStates {
  String error;
  GetConfigErrorState(this.error);
}

class ValidateInvitationLoadingState extends ShopStates {}

class ValidateInvitationSucessfulState extends ShopStates {
  int statusCode;
  ValidateInvitationSucessfulState(this.statusCode);
}

class ValidateInvitationErrorState extends ShopStates {
  String error;
  ValidateInvitationErrorState(this.error);
}

class GetCouponsLoadingState extends ShopStates {}

class GetCouponsSucessfulState extends ShopStates {}

class GetCouponsErrorState extends ShopStates {
  String error;
  GetCouponsErrorState(this.error);
}



class CheckCouponsLoadingState extends ShopStates {}

class CheckCouponsSucessfulState extends ShopStates {}

class CheckCouponsErrorState extends ShopStates {
  String error;
  CheckCouponsErrorState(this.error);
}

class GetPriceDeliveryLoadingState extends ShopStates {}

class GetPriceDeliverySucessfulState extends ShopStates {}

class GetPriceDeliveryErrorState extends ShopStates {
  String error;
  GetPriceDeliveryErrorState(this.error);
}

class getStoresNearLoadingState extends ShopStates {}

class getStoresNearSucessfulState extends ShopStates {}

class getStoresNearErrorState extends ShopStates {
  String error;
  getStoresNearErrorState(this.error);
}
class GetOfferDataLoadingState extends ShopStates {}

class GetOfferDataSucessfulState extends ShopStates {
  final List filters;
  GetOfferDataSucessfulState(this.filters);
}
class GetOfferDataErrorState extends ShopStates {
  String error;
  GetOfferDataErrorState(this.error);
}
class IncrementCartState extends ShopStates{}
class DecrementCartState extends ShopStates{}