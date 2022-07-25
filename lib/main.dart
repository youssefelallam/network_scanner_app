import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> ips = [];
  double percent = 0.0;
  bool isEnd = true;
  bool btn = true;

  scan_network() async {
    final info = NetworkInfo();
    final scanner = LanScanner();
    setState(() {
      isEnd = true;
      btn = false;
      ips = [];
      percent = 0.0;
    });

    final String? ip = await info.getWifiIP();
    final String subnet = ip!.substring(0, ip.lastIndexOf('.'));

    final stream = scanner.icmpScan(subnet, progressCallback: (progress) {
      setState(() {
        percent = progress;
        if (percent == 1.0) {
          isEnd = false;
          btn = true;
        }
      });
    });

    stream.listen((HostModel device) {
      ips.add(device.ip);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Network Scanner'),
        actions: [
          IconButton(
            onPressed: btn ? scan_network : null,
            icon: Icon(Icons.wifi_find),
          ),
        ],
      ),
      body: Center(
        child: isEnd
            ? InkWell(
                onTap: btn ? scan_network : null,
                child: CircularPercentIndicator(
                    radius: 90.0,
                    lineWidth: 16.0,
                    percent: percent,
                    center: Text(
                      "${(percent * 100).toStringAsFixed(0)} %",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    progressColor: Colors.red),
              )
            : ListView.builder(
                itemCount: ips.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 8,
                    color: Colors.red,
                    child: ListTile(
                      leading: Icon(Icons.dns, color: Colors.white),
                      title: Text(
                        ips[index],
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
