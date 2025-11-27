import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ShimmerGridPlaceholder extends StatefulWidget {
  final int count;
  const ShimmerGridPlaceholder({super.key, this.count = 6});

  @override
  State<ShimmerGridPlaceholder> createState() => _ShimmerGridPlaceholderState();
}

class _ShimmerGridPlaceholderState extends State<ShimmerGridPlaceholder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmerBox() {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
              stops: [
                (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
                (_shimmerAnim.value).clamp(0.0, 1.0),
                (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: Alignment(-1, -0.3),
              end: Alignment(1, 0.3),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create a simple 2-column grid of shimmer boxes mimicking recipe cards
    return MasonryGridView.count(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: widget.count,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 180 + (index % 2 == 0 ? 0 : 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildShimmerBox(),
          ),
        );
      },
    );
  }
}