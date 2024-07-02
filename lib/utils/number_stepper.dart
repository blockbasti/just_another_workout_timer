import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';

import '../generated/l10n.dart';
import 'utils.dart';

/// display a value with + and - buttons
// ignore: must_be_immutable
class NumberStepper extends StatefulWidget {
  NumberStepper({
    super.key,
    required this.lowerLimit,
    required this.upperLimit,
    required this.value,
    required this.valueChanged,
    required this.formatNumber,
    required this.largeSteps,
  });

  final int lowerLimit;
  final int upperLimit;
  final double iconSize = 16;
  int value;
  final ValueChanged<int> valueChanged;
  final bool formatNumber;
  final bool largeSteps;

  @override
  CustomStepperState createState() => CustomStepperState();
}

class CustomStepperState extends State<NumberStepper> {
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

  Widget _editableTextField() {
    if (_isEditingText) {
      _editingController.value =
          TextEditingValue(text: widget.value.toString());
      return Center(
        child: SizedBox(
          width: 112,
          child: TextField(
            maxLines: 1,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            keyboardType: TextInputType.number,
            //maxLength: 4,
            inputFormatters: [
              LengthLimitingTextInputFormatter(5),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onSubmitted: (newValue) {
              setState(() {
                var oldVal = widget.value;
                try {
                  widget.value = int.parse(newValue);
                } on FormatException {
                  widget.value = oldVal;
                } finally {
                  widget.valueChanged(widget.value);
                  _isEditingText = false;
                }
              });
            },
            autofocus: true,
            controller: _editingController,
            decoration: InputDecoration(suffixText: S.of(context).seconds),
          ),
        ),
      );
    }
    return InkWell(
      onTap: () {
        setState(() {
          _isEditingText = true;
        });
      },
      child: NumberPicker(
        itemHeight: 32,
        value: widget.value,
        minValue: widget.lowerLimit,
        step: 10,
        itemCount: 3,
        haptics: true,
        zeroPad: false,
        maxValue: widget.upperLimit,
        textMapper: (value) => Utils.formatSeconds(int.parse(value)),
        onChanged: (value) {
          setState(() {
            widget.value = value;
            widget.valueChanged(value);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.largeSteps
      ? Container(
          //width: widget.iconSize*2,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _editableTextField(),
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
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
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${widget.formatNumber ? Utils.formatSeconds(widget.value) : widget.value}',
                style: TextStyle(
                  fontSize: widget.iconSize * 1.2,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
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
