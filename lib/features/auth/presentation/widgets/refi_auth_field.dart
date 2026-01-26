import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/utils/responsive_utils.dart';

class RefiAuthField extends StatefulWidget {
  final String? hintText;
  final String? label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? errorText;

  const RefiAuthField({
    super.key,
    this.hintText,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.errorText,
  });

  @override
  State<RefiAuthField> createState() => _RefiAuthFieldState();
}

class _RefiAuthFieldState extends State<RefiAuthField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h(context)),
        ],
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(24.r(context)),
            border: Border.all(
              color: widget.errorText != null
                  ? AppColors.errorRed
                  : AppColors.inputBorder,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.p24.w(context), // Updated to 24 padding
                vertical: 16.h(context),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: Theme.of(
                        context,
                      ).iconTheme.copyWith(color: AppColors.textPlaceholder),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textPlaceholder,
                        size: 20.sp(context),
                      ),
                      onPressed: _toggleVisibility,
                    )
                  : (widget.suffixIcon != null
                      ? IconTheme(
                          data: Theme.of(context).iconTheme.copyWith(
                                color: AppColors.textPlaceholder,
                              ),
                          child: widget.suffixIcon!,
                        )
                      : null),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: 6.h(context)),
          Padding(
            padding: EdgeInsets.only(right: 12.w(context)),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: AppColors.errorRed,
                fontSize: 12.sp(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
