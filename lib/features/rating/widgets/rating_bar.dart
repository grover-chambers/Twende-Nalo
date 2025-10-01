import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final bool showRating;
  final int maxRating;

  const RatingBar({
    super.key,
    required this.rating,
    this.size = 20.0,
    this.color = Colors.amber,
    this.showRating = false,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          if (index < rating.floor()) {
            return Icon(
              Icons.star,
              size: size,
              color: color,
            );
          } else if (index < rating.ceil()) {
            return Icon(
              Icons.star_half,
              size: size,
              color: color,
            );
          } else {
            return Icon(
              Icons.star_border,
              size: size,
              color: color,
            );
          }
        }),
        if (showRating) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

class InteractiveRatingBar extends StatefulWidget {
  final double initialRating;
  final double size;
  final Color color;
  final ValueChanged<double> onRatingChanged;
  final int maxRating;

  const InteractiveRatingBar({
    super.key,
    this.initialRating = 0.0,
    this.size = 30.0,
    this.color = Colors.amber,
    required this.onRatingChanged,
    this.maxRating = 5,
  });

  @override
  State<InteractiveRatingBar> createState() => _InteractiveRatingBarState();
}

class _InteractiveRatingBarState extends State<InteractiveRatingBar> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1.0;
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Icon(
            _currentRating >= index + 1.0
                ? Icons.star
                : _currentRating > index
                    ? Icons.star_half
                    : Icons.star_border,
            size: widget.size,
            color: widget.color,
          ),
        );
      }),
    );
  }
}

class RatingDistributionBar extends StatelessWidget {
  final Map<int, int> ratingCounts;
  final int totalReviews;
  final double height;
  final Color filledColor;
  final Color emptyColor;

  const RatingDistributionBar({
    super.key,
    required this.ratingCounts,
    required this.totalReviews,
    this.height = 8.0,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(5, (index) {
        final rating = 5 - index;
        final count = ratingCounts[rating] ?? 0;
        final percentage = totalReviews > 0 ? count / totalReviews : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              SizedBox(
                width: 12,
                child: Text(
                  '$rating',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: emptyColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: filledColor,
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).reversed.toList(),
    );
  }
}
