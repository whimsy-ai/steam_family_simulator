import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data.dart';
import 'http.dart';
import 'main_controller.dart';

Timer? _lazyTimer;

class Settings extends GetView<MainController> {
  @override
  Widget build(BuildContext context) {
    final c = TextEditingController(text: Data.proxy);
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  ListTile(
                    title: TextField(
                      controller: c,
                      decoration: InputDecoration(
                        labelText: '网络代理',
                        prefixText: 'http://',
                        suffix: IconButton(
                          iconSize: 14,
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            Data.proxy = null;
                          },
                        ),
                      ),
                      onChanged: (v) {
                        _lazyTimer?.cancel();
                        _lazyTimer = Timer(Duration(milliseconds: 200), () {
                          print('设置代理 $v');
                          Data.proxy = v.isEmpty ? null : v;
                          Http.init(proxy: v);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
