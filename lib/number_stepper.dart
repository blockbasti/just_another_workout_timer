import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'utils.dart';

/// display a value with + and - buttons
// ignore: must_be_immutable
class NumberStepper extends StatefulWidget {
  NumberStepper(
      {required this.lowerLimit,
      required this.upperLimit,
      required this.value,
      required this.valueChanged,
      required this.formatNumber,
      required this.largeSteps});

  final int lowerLimit;
  final int upperLimit;
  final double iconSize = 16;
  int value;
  final ValueChanged<int> valueChanged;
  final bool formatNumber;
  final bool largeSteps;

  @override
  _CustomStepperState createState() => _CustomStepperState();
}

class _CustomStepperState extends State<NumberStepper> {
  @override
  Widget build(BuildContext context) => widget.largeSteps
      ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 24,
              child: FloatingActionButton(
                heroTag: null,
                child: Text(
                  '-5',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  setState(() {
                    widget.value = widget.value == widget.lowerLimit
                        ? widget.lowerLimit
                        : widget.value -= 5;
                  });
                  widget.valueChanged(widget.value);
                },
              ),
            ),
            Container(
              width: 24,
              child: FloatingActionButton(
                child: Text('-1', style: TextStyle(color: Colors.white)),
                heroTag: null,
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  setState(() {
                    widget.value = widget.value == widget.lowerLimit
                        ? widget.lowerLimit
                        : widget.value -= 1;
                  });
                  widget.valueChanged(widget.value);
                },
              ),
            ),
            Container(
              //width: widget.iconSize*2,
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${widget.formatNumber ? Utils.formatSeconds(widget.value) : widget.value}',
                style: TextStyle(
                    fontSize: widget.iconSize * 0.9,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 24,
              child: FloatingActionButton(
                heroTag: null,
                child: Text(
                  '+1',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  setState(() {
                    widget.value = widget.value == widget.upperLimit
                        ? widget.upperLimit
                        : widget.value += 1;
                  });
                  widget.valueChanged(widget.value);
                },
              ),
            ),
            Container(
              width: 24,
              child: FloatingActionButton(
                heroTag: null,
                child: Text('+5', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  setState(() {
                    widget.value = widget.value == widget.upperLimit
                        ? widget.upperLimit
                        : widget.value += 5;
                  });
                  widget.valueChanged(widget.value);
                },
              ),
            ),
          ],
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  widget.value = widget.value == widget.lowerLimit
                      ? widget.lowerLimit
                      : widget.value -= 1;
                });
                widget.valueChanged(widget.value);
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${widget.formatNumber ? Utils.formatSeconds(widget.value) : widget.value}',
                style: TextStyle(
                    fontSize: widget.iconSize * 0.9,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  widget.value = widget.value == widget.upperLimit
                      ? widget.upperLimit
                      : widget.value += 1;
                });
                widget.valueChanged(widget.value);
              },
            ),
          ],
        );
}
