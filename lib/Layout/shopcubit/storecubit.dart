import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopapp/apiService/store/storeApi.dart';
import 'package:shopapp/class/data.dart';
import 'package:shopapp/shared/components/components.dart';
import 'package:shopapp/shared/components/constants.dart';
import 'package:shopapp/shared/network/remote/dio_helper.dart';
import '../../shared/network/remote/cachehelper.dart';
import 'storestate.dart';
import 'package:http/http.dart' as http;
final dataService = new DataSource();
class StoreCubit extends Cubit<ShopStates> {
  StoreCubit() : super(ShopIntiaialStates());
  static StoreCubit get(context) => BlocProvider.of(context);

  bool CheckoutApiLoading = true;
  List<dynamic> cuisines = [];
  List<dynamic> offers = [];
  List<dynamic> menu = [];
  List<dynamic> dishes = [];
  List<dynamic> itemCart=[];
  bool isloading = true;
  List categories = [];
  List<dynamic> stores = [];
  int qty = 1;
  bool isRestaurantsLoading = false;
  bool isNearStoresLoading = false;
  bool isCategoriesLoading = false;
  bool isSlidersLoading = false;
  List<dynamic> topChoise =[];
  int randomIndex;
  int oldrandomIndex;
  var Categories;
  bool ispriceLoading = false;
  List PriceDeliverys = [];
  List products = [];
  bool isStoreExit = false;
  bool isinCart = false;
  List search = [];
  var timestart =null;
  var timeEnd=null;
  Map<String,dynamic> store;
  List myorders = [];
  Map<String, dynamic> myorder = {};
  bool isload = false;
  bool isorderLoading= false;
  bool isCouponLoading= false;
  bool isValid = null;
  List<dynamic>coupons=[];
  bool isValidLoading = true;
  bool isSearchLoading = false;
  var percentage = null;
  Map coupon ={};
  bool isCouponValid = false;
  List<dynamic> storesNear = [];
  double latitud = Cachehelper.getData(key: "latitude");
  double longitud = Cachehelper.getData(key: "longitude");
  int getRandomNumberFromList(stors) {
    if (stors.isEmpty) {
      throw ArgumentError("The list must not be empty.");
    }
    return stors[Random().nextInt(stors.length)];
  }

  double calculatePrice(price,percentage){
    percentage = percentage / 100;
    return price - (price * percentage);
  }


  void minus(){
    if (qty > 1) {
      qty--;
      emit(minusSucessfulState());
    }
  }

  void plus(){
      qty++;
     emit(pluseSucessfulState());
  }

  addToCart({product,productStoreId,productId,Qty,attributes,storeStats,offers,storeName,prixOffer}){
    print('inside the cart :${attributes}');
    products = [];


    if(dataService.itemsCart.length==0){
      dataService.itemsCart.add({
        "storeName":storeName,
        "storeStatus":storeStats,
        "productStoreId":productStoreId,
        "id":product['id'],
        "quantity":Qty,
        "name":product['name'],
        "descripton":product['description'],
        "image":product['image'],
        "price":prixOffer!=null?prixOffer:double.tryParse(product['price']),
        "attributes":products,
        "offers":offers,
        "priceold":product['price']
      });
      attributes.forEach((e){
        e['products'].forEach((e){
          products.add({
            "id":e['id'],
            "quantity":1,
            "price":e['price'],
            "name":e['name']
          });
        });
      });

      emit(AddtoCartSucessfulState(getTotalPrice()));
      isinCart = true;
      getTotalPrice();
    }else{
      print(attributes);
      print(products);
      products = [];
      var cantainStore = dataService.itemsCart.where((element)=>element['productStoreId']==productStoreId).toList();

      if(cantainStore.isNotEmpty){
        print(dataService.itemsCart);
        var containProduct = dataService.itemsCart.where((element)=> element['id'] == product['id'] && checkAttrubutes(element['attributes'],products) ).toList();
        if(containProduct.isEmpty){
          products = [];

          attributes.forEach((e) {
            e['products'].forEach((e) {
              products.add({
                "id":e['id'],
                "quantity":1,
                "price":e['price'],
                "name":e['name']
              });
            });
          });

          dataService.itemsCart.add({
            "storeName":storeName,
            "storeStatus":storeStats,
            "productStoreId":productStoreId,
            "id":product['id'],
            "quantity":Qty,
            "name":product['name'],
            "descripton":product['description'],
            "image":product['image'],
            "price":prixOffer!=null?prixOffer:double.tryParse(product['price']),
            "attributes":products,
            "offers":offers,
            "priceold":product['price']
          });


          emit(AddtoCartSucessfulState(getTotalPrice()));
          isinCart = true;
          getTotalPrice();
        }
        else{
          containProduct.forEach((element){
            element['quantity']=element['quantity']+Qty;
          });
          print('list orders:${dataService.itemsCart}');
          getTotalPrice();
          emit(AddtoCartSucessfulState(getTotalPrice()));
        }
      }else{
        isStoreExit = true;
        emit(ChangevalueState());
        print('you cant add this store to the cart');
      }
    }
  }

  IncrementCart({product}){
    var cantainStore = dataService.itemsCart.where((element)=>element['productStoreId']== product['productStoreId']).toList();
    if(cantainStore.isNotEmpty){
      if(dataService.itemsCart.contains(product)){
        dataService.itemsCart[dataService.itemsCart.indexOf(product)]['quantity'] += 1;
        emit(IncrementCartState());
      }
    }

  }

  DecrementCart({product}){
    var cantainStore = dataService.itemsCart.where((element)=>element['productStoreId']== product['productStoreId']).toList();
    if(cantainStore.isNotEmpty){
      if(dataService.itemsCart.contains(product)){
        if(dataService.itemsCart[dataService.itemsCart.indexOf(product)]['quantity'] == 1){
           dataService.itemsCart.removeAt(dataService.itemsCart.indexOf(product));
        }else {
          dataService.itemsCart[dataService.itemsCart.indexOf(product)]['quantity'] -= 1;
        }
        emit(DecrementCartState());
      }
    }

  }

  checkAttrubutes(attributes,newAttributes){
    if(attributes.length == newAttributes.length){
      attributes.forEach((e){
        if(!newAttributes.firstWhere((att) => att['id'] == e['id'],orElse: () => null)){
          return false;
        }
      });
      return true;
    }
    return false;
  }

  void removeItem({product, productStoreId,productId,Qty}){
    var contain = dataService.itemsCart.where((element) => element['id']==product['id']);
    contain.forEach((element) {
      element['quantity']=element['quantity']-Qty;
      if (element['quantity'] == 0) {
        dataService.itemsCart.removeWhere((item) => item["id"]==product['id']);
        dataService.productsCart.removeWhere((item) => item["id"]==product['id']);
        emit(RemovetoCartSucessfulState());
      }
    });

  }

  getCartItem(){
    return dataService.itemsCart.length;
  }

  double getTotalPrice(){
    double totalPrice = 0.0;
    dataService.itemsCart.forEach((element){
      if(element['attributes'].length==0){
        totalPrice = totalPrice + element['price'] * element['quantity'];
      }else{
        totalPrice = totalPrice + element['price'] * element['quantity'];
        for(var i = 0 ;i<element['attributes'].length;i++){
            totalPrice = totalPrice + double.tryParse(element['attributes'][i]['price']);
        }
      }
    });
    return totalPrice;
  }

  Future UpdateProfile(data) async{
    String access_token = Cachehelper.getData(key: "token");
    emit(UpdateProfileLoadingState());
    http.Response response =
    await http.put(
        Uri.parse('https://api.canariapp.com/v1/client/profile'),
        headers:{'Content-Type':'application/json','Accept':'application/json',
          'Authorization': 'Bearer ${access_token}'},
        body:jsonEncode(data)
    ).then((value) {
      var responsebody = jsonDecode(value.body);
      print('============================================================');
      printFullText('data : ${responsebody.toString()}');
      Cachehelper.sharedPreferences.setString("first_name",responsebody['first_name']);
      Cachehelper.sharedPreferences.setString("last_name",responsebody['last_name']);
      Cachehelper.sharedPreferences.setString("phone",responsebody['phone']);
      print('============================================================');
      emit(UpdateProfileSucessfulState());
    }).catchError((error){
      var responsebody = jsonDecode(error);
      printFullText('error ${responsebody.toString()}');
      emit(UpdateProfileErrorState(error.toString()));
    });
    return response;
  }

  GetProfile() async{
    String access_token = Cachehelper.getData(key: "token");
    String invitation_code = Cachehelper.getData(key: "codeInvitation");
    emit(UpdateProfileLoadingState());

    if(invitation_code==null){
      http.Response response = await http.get(
        Uri.parse('https://api.canariapp.com/v1/client/profile'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
      ).then((value) {
        var responsebody = jsonDecode(value.body);
        print('============================================================');
        printFullText(responsebody.toString());
        Cachehelper.sharedPreferences.setString("codeInvitation",responsebody['invitation_code']);
        print('============================================================');
        emit(UpdateProfileSucessfulState());
      }).catchError((error){
        printFullText('error ${error.toString()}');
        emit(UpdateProfileErrorState(error.toString()));
      });
      return response;
    }else{
      emit(UpdateProfileSucessfulState());
    }


  }

  getSearchData(String value) {
    String access_token = Cachehelper.getData(key: "token");
    ispriceLoading = false;
    isSearchLoading = false;
    emit(GetSearchLoadingState());
    http.get(
      Uri.parse('https://api.canariapp.com/v1/client/stores?city=1&search=${value}&all=true&locale=${lg}'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
    ).then((value) {
      var responsebody = jsonDecode(value.body);
      search = responsebody;
      isSearchLoading = true;
      ispriceLoading = true;
      emit(GetSearchSucessfulState());
    }).catchError((error) {
      print(error.toString());
      emit(GetSearchErrorState(error.toString()));
    });
  }

  FilterData({latitude,longitude,text}) {
    emit(GetFilterDataLoadingState());
    isloading = false;
    FilterDataApi(latitude:latitude,longitude: longitude,elements:text).then((value){
      isloading = true;
      List<String> slugs = [];
      value.forEach((element) {
        slugs.add(element['slug']);
      });
      if(slugs.isNotEmpty)
      GetDeliveryPrice(slugs);
      emit(GetFilterDataSucessfulState(value));
    }).catchError((error) {
      print(error.toString());
      emit(GetFilterDataErrorState(error.toString()));
    });
  }

  getcategoriesData() {
    emit(GetCategoryDataLoadingState());
    isCategoriesLoading = false;
    getCategorieApi().then((value) {
      categories = value;
      isCategoriesLoading = true;

      emit(GetCategoryDataSucessfulState());
    }).catchError((error) {
      print(error.toString());
      emit(GetCategoryDataErrorState(error.toString()));
    });
  }

  getStoresData({latitude,longitude}){

    emit(GetResturantDataLoadingState());
    isRestaurantsLoading = false;
    getStoresApi(latitude:latitude,longitude: longitude,).then((value){

    stores = value;



    topChoise = stores.where((e) => (e['group_products'] as List).isNotEmpty).toList();
    if(topChoise.length!=0){
      var listnumber = [];

      for(var i = 0 ;i < topChoise.length;i++){
        listnumber.add(i);
      }

      randomIndex = getRandomNumberFromList(listnumber);

      if(listnumber.length>1){
        listnumber.removeAt(randomIndex);
      }

      oldrandomIndex = getRandomNumberFromList(listnumber);
      Categories = topChoise[randomIndex]['categories'].length >= 3 ?
      topChoise[randomIndex]['categories'].sublist(0, 3) :
      topChoise[randomIndex]['categories'];
      List<String> slugs = [];
      stores.forEach((element) {
        slugs.add(element['slug']);
      });
      isRestaurantsLoading = true;
      GetDeliveryPrice(slugs);
      emit(GetResturantDataSucessfulState());
    }else{
      // List<String> slugs = [];
      // stores.forEach((element) {
      //   slugs.add(element['slug']);
      // });
      // GetDeliveryPrice(slugs);

      List<String> slugs = [];
      stores.forEach((element) {
        slugs.add(element['slug']);
      });

      GetDeliveryPrice(slugs);
      isRestaurantsLoading = true;
      emit(GetResturantDataSucessfulState());
    }
    }).catchError((error) {
     print('----------------------------------');
     print(error.toString());
     print('----------------------------------');
      emit(GetResturantDataErrorState(error.toString()));
    });
  }

  GetDeliveryPrice(List slugs)async{
    String result = 'slugs[]=' + slugs.map((slug) => Uri.encodeQueryComponent(slug)).join('&slugs[]=');
    ispriceLoading = false;
    emit(GetPriceDeliveryLoadingState());
    String access_token = Cachehelper.getData(key: "token");
    http.Response response = await http.get(
    Uri.parse('https://www.api.canariapp.com/v1/client/stores/get_delivery_price?$result&latitude=${latitud}&longitude=${longitud}'),
    headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
    ).then((value){
      var responsebody = jsonDecode(value.body);
      print('----------------------------------');
      print(responsebody);
      print('----------------------------------');
      PriceDeliverys = responsebody;
      ispriceLoading = true;
     emit(GetPriceDeliverySucessfulState());
    }).catchError((onError){
    print(onError.toString());
    emit(GetPriceDeliveryErrorState(onError.toString()));
    });

    return response;

  }

  getStoreData({String slug}) {
    emit(GetResturantPageDataLoadingState());
    getStoreApi(slug: slug,latitude:latitude ,longitude: longitude).then((value) {
    isloading = true;
    store = value;
    dataService.store = store;
    storeLatitude = store['latitude'];
    storeLongitude = store['longitude'];
     GetDeliveryPrice([slug]);
    emit(GetResturantPageDataSucessfulState());
    }).catchError((error) {
    print(error.toString());
    emit(GetResturantPageDataErrorState(error.toString()));
    });
  }

  CheckoutApi(payload)async{
    isloading = false;
    CheckoutApiLoading = false;
    String access_token = Cachehelper.getData(key: "token");
    printFullText(access_token.toString());
    printFullText('checkout :${payload}');
    emit(CheckoutLoadingState());
    http.Response response = await http.post(
        Uri.parse('https://www.api.canariapp.com/v1/client/orders'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
        body:jsonEncode(payload)
    ).then((value) {
      var responsebody = jsonDecode(value.body);
      print('--------------------------------------------------------------------');
      CheckoutApiLoading = true;
      print('--------------------------------------------------------------------');
      emit(CheckoutSucessfulState());
    }).catchError((error){
      printFullText(error.toString());
      emit(CheckoutErrorState(error.toString()));
    });

    return response;
  }

  Myorder(refcode)async{
    String access_token = Cachehelper.getData(key: "token");
        emit(MyorderLoadingState());
    isload = false;
    http.Response response = await http.get(
        Uri.parse('https://www.api.canariapp.com/v1/client/orders/${refcode}?include=products,store,reviews'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value) {
      var responsebody = jsonDecode(value.body);
      myorder = responsebody;

      isload = true;
       dataService.itemsCart.clear();
      emit(MyorderSucessfulState(responsebody));
    }).catchError((error){

      printFullText(error.toString());
      emit(MyorderErrorState(error.toString()));
    });
    printFullText(response.toString());
    return response;
  }

  Myorders()async{
    String access_token = Cachehelper.getData(key: "token");
    emit(MyordersLoadingState());
    isorderLoading = false;
    http.Response response = await http.get(
        Uri.parse('https://www.api.canariapp.com/v1/client/orders?include=products,store'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value) {
      var responsebody = jsonDecode(value.body);
      myorders = responsebody['data'];
      isorderLoading = true;
      isload = true;
      emit(MyordersSucessfulState(responsebody));
    }).catchError((error){
      printFullText(error.toString());
      emit(MyordersErrorState(error.toString()));
    });
    return response;
  }

  ValidateInvitation(invitation_code)async{
    emit(ValidateInvitationLoadingState());
    await http.post(
        Uri.parse('https://api.canariapp.com/v1/client/validate_invitation_code'),
        headers:{
          'Accept':'application/json',
        },
        body: {
          'invitation_code':"${invitation_code}"
        }
    ).then((value){
      if(value.statusCode==200){
        isValid = true;
        emit(ValidateInvitationSucessfulState(value.statusCode));

      }else{
        emit(ValidateInvitationSucessfulState(value.statusCode));
        isValid = false;
        print('error');

      }
    }).catchError((error){
      print(error);
      emit(ValidateInvitationErrorState(error.toString()));
      isValid = false;

    });
  }

  GetCoupons()async{
    String access_token = Cachehelper.getData(key: "token");
    isCouponLoading = false;
    printFullText(access_token.toString());
    emit(GetCouponsLoadingState());
    await http.get(
        Uri.parse('https://api.canariapp.com/v1/client/coupons/get_available_coupons'),
        headers:{
          'Content-Type':'application/json',
          'Accept':'application/json',
          'Authorization': 'Bearer ${access_token}'
         }
    ).then((value){
      emit(GetCouponsSucessfulState());
      var responsebody = jsonDecode(value.body);
      isCouponLoading = true;
      coupons = responsebody['data'];
    }).catchError((error){
      print(error);
      emit(GetCouponsErrorState(error.toString()));
    });
  }

  CheckCoupons(code_coupon)async{
    String access_token = Cachehelper.getData(key: "token");
    isValidLoading = false;
    printFullText(access_token.toString());
    emit(CheckCouponsLoadingState());
    await http.post(
    Uri.parse('https://api.canariapp.com/v1/client/coupons/check_coupon'),
        headers:{
          'Accept':'application/json',
          'Authorization': 'Bearer ${access_token}'
        },
        body: {
        "coupon_code":code_coupon
        }
    ).then((value){
      emit(CheckCouponsSucessfulState());
      var responsebody = jsonDecode(value.body);
      if(responsebody['status']=='Available'){
        isValid = true;
        coupon = responsebody;
      }else{
        isValid = false;
      }
      isValidLoading = true;
      printFullText(responsebody.toString());
    }).catchError((error){
      print(error);
      isValid = false;
      emit(CheckCouponsErrorState(error.toString()));
    });
  }

  getStoresNear({latitude,longitude})async{
    isNearStoresLoading = false;
    await getStoresNearApi(latitude:latitude,longitude:longitude).then((value){


      storesNear = value;
      List<String> slugs = [];
      storesNear.forEach((element) {
        slugs.add(element['slug']);
      });
      GetDeliveryPrice(slugs);
      isNearStoresLoading = true;

    }).catchError((error){

      print(error.toString());
    });
  }

  getConfig() {
    isloading = false;
    emit(GetConfigLoadingState());
    DioHelper.getData(
      url: 'https://api.canariapp.com/v1/client/config',
    ).then((value) {
      value.data.forEach((e){
        if(e['key']=='payment_by_card'){
            dataService.payment_by_card = e['value'];
        }

        if(e['key']=='weather_fee'){
            dataService.weather_fee =e['value'];
        }

        if(e['key']=='service_fee_calculation'){
            dataService.value = e['value'];
        }

        if(e['key']=='share_app'){
            share_app = e['value'];
        }

        if(e['key']=='coupon_page'){
            coupon_page = e['value'];
        }

        if(e['key']=='start_with_location'){
            start_with_location = e['value'];
        }

        if(e['key']=='location_alert'){
            location_alert = e['value'];
        }

      });
      isloading = true;
      emit(GetConfigSucessfulState());
    }).catchError((error) {
      print(error.toString());
      emit(GetConfigErrorState(error.toString()));
    });
  }
  getStoresPopular({latitude,longitude})async{
    isNearStoresLoading = false;
    await getStoresNearApi(latitude:latitude,longitude:longitude).then((value){


      storesNear = value;
      List<String> slugs = [];
      storesNear.forEach((element) {
        slugs.add(element['slug']);
      });
      GetDeliveryPrice(slugs);
      isNearStoresLoading = true;

    }).catchError((error){

      print(error.toString());
    });
  }
}


