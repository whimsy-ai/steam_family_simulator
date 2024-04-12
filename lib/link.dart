import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

WidgetSpan linkSpan(String url, {String? text}) => WidgetSpan(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => launchUrlString(url),
          child: SizedBox(
            height: 20,
            child: Text(
              text ?? url,
              style: TextStyle(
                color: Colors.blue,
                height: 0
              ),
            ),
          ),
        ),
      ),
    );
