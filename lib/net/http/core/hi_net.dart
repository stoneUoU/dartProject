import 'package:FlutterProject/net/http/core/dio_adapter.dart';
import 'package:singleton/singleton.dart';

import '../request/base_request.dart';
import 'hi_error.dart';
import 'hi_net_adapter.dart';

///1.支持网络库插拔设计，且不干扰业务层
///2.基于配置请求请求，简洁易用
///3.Adapter设计，扩展性强
///4.统一异常和返回处理
class HiNet {
  factory HiNet() => Singleton.lazy(() => HiNet._());

  /// Private constructor
  HiNet._() {}

  Future fire(BaseRequest request) async {
    HiNetResponse response = HiNetResponse(
        data: "", request: request, statusCode: 200, statusMessage: "success");
    var error;
    try {
      response = await send(request);
    } on HiNetError catch (e) {
      error = e;
      response = e.data;
      printLog(e.message);
    } catch (e) {
      //其它异常
      error = e;
      printLog(e);
    }
    var result = response.data;
    printLog(result);
    var status = response.statusCode;
    switch (status) {
      case 200:
        return result;
        break;
      case 401:
        throw NeedLogin();
        break;
      case 403:
        throw NeedAuth(result.toString(), data: result);
        break;
      default:
        throw HiNetError(status!, result.toString(), data: result);
        break;
    }
  }

  Future<HiNetResponse<T>> send<T>(BaseRequest request) async {
    ///使用Dio发送请求
    HiNetAdapter adapter = DioAdapter();
    return adapter.send(request);
  }

  void printLog(log) {
    // print('hi_net:' + log.toString());
  }
}
