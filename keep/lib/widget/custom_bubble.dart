import 'dart:math';
import 'package:flutter/material.dart';

// 尖角方向枚举
enum BubbleAngleDirection { left, right }

class BubbleWidget extends StatelessWidget {
 
  BubbleWidget(
    this.data, {
    Key key,
    this.textStyle = const TextStyle(color: Colors.black, fontSize: 13),
    this.maxWidth,
    this.color = Colors.lightGreen,
    this.radius = 10,
    this.padding = 10,
    //
    this.angle = 60,
    this.angleHeight = 8,
    this.anglePos = BubbleAngleDirection.left,
  }) : super(key: key);

  final String data; //文本内容
  final TextStyle textStyle;//文本样式

  final double maxWidth; //最大宽带
  final Color color; //背景颜色
  final double radius; 
  final double padding; 

  // 尖角
  final double angle; //尖角角度
  final double angleHeight; //尖角高度
  final BubbleAngleDirection anglePos;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _BubbleCanvas(
            context: context,
            data: data,
            textStyle: textStyle,
            // 默认最大宽带为屏幕宽度的3/4
            maxWidth: maxWidth == null ? MediaQuery.of(context).size.width * 0.75 : maxWidth,
            color: color,
            padding: padding,
            radius: radius,
            //
            angle: angle,
            angleHeight: angleHeight,
            anglePos: anglePos));
  }
}

class _BubbleCanvas extends CustomPainter {
  _BubbleCanvas({
    this.context,
    this.data,
    this.textStyle,
    //
    this.maxWidth,
    this.color,
    this.padding,
    this.radius,
    //
    this.angle,
    this.angleHeight,
    this.anglePos,
  });

  final BuildContext context;
  final String data;
  final TextStyle textStyle;

  final double maxWidth;
  final Color color;
  final double padding;
  final double radius;

  final double angle;
  final double angleHeight;
  final BubbleAngleDirection anglePos;

  double _angle(angle) => angle * pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    // 气泡组件的实际宽度
    double width = 0;
    double maxHeight = 0;
    int lines = 1;
    // 计算文字内容所需的宽和高
    data.runes.forEach((element) {
      String str = String.fromCharCode(element);
      TextPainter tp = TextPainter(text: TextSpan(style: textStyle, text: str), textDirection: TextDirection.rtl);
      tp.layout();
      if (width + tp.width > (maxWidth - padding)) {
        lines++;
        width = 0;
      }
      if (maxHeight < tp.height) maxHeight = tp.height;

      width += tp.width;
    });

    width = lines > 1 ? maxWidth : (width + padding * 2 + angleHeight);
    //气泡组件的实际高度
    double height = maxHeight * lines + padding * 2;
    double angleLength = angleHeight * tan(_angle(angle * 0.5));
    // 重新计算坐标原点, 注意Row的mainAxisAlignment属性会影响组件的坐标原点,需要重新计算
    Offset origin = Offset(anglePos == BubbleAngleDirection.left ? 0 : -width, -height / 2);

    Path path = Path();

    //左上角圆角
    Offset leftTop = Offset(anglePos == BubbleAngleDirection.left ? radius + angleHeight : radius, radius);
    path.arcTo(Rect.fromCircle(center: Offset(origin.dx + leftTop.dx, origin.dy + leftTop.dy), radius: radius), pi, pi * 0.5, false);

    // 右上角圆角
    Offset rightTop = Offset(anglePos == BubbleAngleDirection.right ? width - angleHeight - radius : width - radius, radius);
    path.arcTo(Rect.fromCircle(center: Offset(origin.dx + rightTop.dx, origin.dy + rightTop.dy), radius: radius), -pi * 0.5, pi * 0.5, false);

    if (anglePos == BubbleAngleDirection.right) {
      path.lineTo(origin.dx + width - angleHeight, origin.dy + padding + maxHeight / 2 - angleLength);
      path.lineTo(origin.dx + width, origin.dy + padding + maxHeight / 2);
      path.lineTo(origin.dx + width - angleHeight, origin.dy + padding + maxHeight / 2 + angleLength);
    }

    // 右下角圆角
    Offset rightBottom = Offset(anglePos == BubbleAngleDirection.right ? width - angleHeight - radius : width - radius, height - radius);
    path.arcTo(Rect.fromCircle(center: Offset(origin.dx + rightBottom.dx, origin.dy + rightBottom.dy), radius: radius), 0, pi * 0.5, false);

    // 左下角圆角
    Offset leftBottom = Offset((anglePos == BubbleAngleDirection.left) ? angleHeight + radius : radius, height - radius);
    path.arcTo(Rect.fromCircle(center: Offset(origin.dx + leftBottom.dx, origin.dy + leftBottom.dy), radius: radius), pi * 0.5, pi * 0.5, false);

    if (anglePos == BubbleAngleDirection.left) {
      path.lineTo(origin.dx + angleHeight, origin.dy + padding + maxHeight / 2 - angleLength);
      path.lineTo(origin.dx, origin.dy + padding + maxHeight / 2);
      path.lineTo(origin.dx + angleHeight, origin.dy + padding + maxHeight / 2 + angleLength);
    }

    path.close();
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true);
    canvas.save();

    // 计算文本内容绘制的起始坐标
    final defautX = anglePos == BubbleAngleDirection.left ? origin.dx + (angleHeight + padding) : origin.dx + padding;
    double offsetX = defautX;
    double offsetY = origin.dy + padding;

    data.runes.forEach((element) {
      String str = String.fromCharCode(element);
      TextPainter tp = TextPainter(text: TextSpan(style: textStyle, text: str), textDirection: TextDirection.rtl);
      tp.layout();
      //横向达到气泡组件的最大宽度时,换行
      if (offsetX + tp.width > (maxWidth - padding)) {
        offsetY += tp.height;
        offsetX = defautX;
      }
      //绘制文本
      //tp.height < maxHeight ? (maxHeight - tp.height) : 0 是因为字母和中文的高度不一样,这样可以让字母和文字底部对齐
      tp.paint(canvas, Offset(offsetX, offsetY + (tp.height < maxHeight ? (maxHeight - tp.height) : 0)));
      offsetX += tp.width;
    });
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}