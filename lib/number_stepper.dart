import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'generated/l10n.dart';
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
  bool _isEditingText = false;
  late TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  Widget _editTitleTextField() {
    if (_isEditingText) {
      return Center(
        child: SizedBox(
            width: 112,
            child: TextField(
                maxLines: 1,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                //maxLength: 4,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4),
                  FilteringTextInputFormatter.digitsOnly
                ],
                onSubmitted: (newValue) {
                  setState(() {
                    var _oldVal = widget.value;
                    try {
                      widget.value = int.parse(newValue);
                    } on FormatException {
                      widget.value = _oldVal;
                    } finally {
                      widget.valueChanged(widget.value);
                      _isEditingText = false;
                    }
                  });
                },
                autofocus: true,
                controller: _editingController,
                decoration:
                    InputDecoration(suffixText: S.of(context).seconds))),
      );
    }
    return InkWell(
        onTap: () {
          setState(() {
            _isEditingText = true;
          });
        },
        child: Text(
          '${widget.formatNumber ? Utils.formatSeconds(widget.value) : widget.value}',
          style:
              TextStyle(fontSize: widget.iconSize, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ));
  }

  @override
  Widget build(BuildContext context) => widget.largeSteps
      ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: ElevatedButton(
                    child: Text(
                      '+1',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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
                  width: 48,
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: ElevatedButton(
                    child: Text('+5',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
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
            ),
            Row(
              children: [
                Container(
                  //width: widget.iconSize*2,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: _editTitleTextField(),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: ElevatedButton(
                    child: Text('-1',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
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
                  width: 48,
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: ElevatedButton(
                    child: Text(
                      '-5',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      setState(() {
                        widget.value = widget.value -5 < widget.lowerLimit
                            ? widget.lowerLimit
                            : widget.value -= 5;
                      });
                      widget.valueChanged(widget.value);
                    },
                  ),
                ),
              ],
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
                    fontSize: widget.iconSize * 1.2,
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
