import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.toskaTint,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: AppColors.toskaDark, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  if (index > 0) const SizedBox(height: 14),
                  children[index],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RequiredFieldLabel extends StatelessWidget {
  const RequiredFieldLabel({
    super.key,
    required this.label,
    this.required = false,
    this.helper,
  });

  final String label;
  final bool required;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 3),
          Text(
            helper!,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
