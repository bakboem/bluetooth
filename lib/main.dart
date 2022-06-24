import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:getxtest/src/ble/ble_device_connector.dart';
import 'package:getxtest/src/ble/ble_device_interactor.dart';
import 'package:getxtest/src/ble/ble_scanner.dart';
import 'package:getxtest/src/ble/ble_status_monitor.dart';
import 'package:getxtest/src/service/permission_service.dart';
import 'package:getxtest/src/ui/ble_status_screen.dart';
import 'package:getxtest/src/ui/device_list.dart';
import 'package:provider/provider.dart';
import 'src/ble/ble_logger.dart';

const _themeColor = Colors.lightGreen;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final _bleLogger = BleLogger();
  final _ble = FlutterReactiveBle();
  final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  final _monitor = BleStatusMonitor(_ble);
  final _connector = BleDeviceConnector(
    ble: _ble,
    logMessage: _bleLogger.addToLog,
  );
  final _serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: _ble.discoverServices,
    readCharacteristic: _ble.readCharacteristic,
    writeWithResponse: _ble.writeCharacteristicWithResponse,
    writeWithOutResponse: _ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: _ble.subscribeToCharacteristic,
    logMessage: _bleLogger.addToLog,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _scanner),
        Provider.value(value: _monitor),
        Provider.value(value: _connector),
        Provider.value(value: _serviceDiscoverer),
        Provider.value(value: _bleLogger),
        StreamProvider<BleScannerState?>(
          create: (_) => _scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => _monitor.state,
          initialData: BleStatus.unknown,
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => _connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Reactive BLE example',
        color: _themeColor,
        theme: ThemeData(primarySwatch: _themeColor),
        home: const HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: PermissonService.checkLocationPermisson(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return Consumer<BleStatus?>(
            builder: (_, status, __) {
              if (status == BleStatus.ready) {
                return const DeviceListScreen();
              } else {
                PermissonService.checkdBlueToothPermisson();
                return BleStatusScreen(status: status ?? BleStatus.unknown);
              }
            },
          );
        }
        return Container();
      });
}
