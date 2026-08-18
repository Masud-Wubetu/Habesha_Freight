import './Ratings.css';

const reviews = [
  {
    name: 'Tigist Worku',
    date: 'Aug 9',
    rating: 5,
    comment: 'Excellent service, all trucks arrived on time!',
    tags: ['On Time', 'Professional'],
  },
  {
    name: 'Sara Bekele',
    date: 'Aug 4',
    rating: 4,
    comment: 'Good coordination, minor delay at departure.',
    tags: ['Professional'],
  },
  {
    name: 'Dawit Haile',
    date: 'Jul 28',
    rating: 5,
    comment: 'Very reliable transport company.',
    tags: ['Reliable', 'On Time'],
  },
];

const ratingBreakdown = [
  { stars: 5, percentage: 72 },
  { stars: 4, percentage: 18 },
  { stars: 3, percentage: 7 },
  { stars: 2, percentage: 2 },
  { stars: 1, percentage: 1 },
];

function Ratings() {
  return (
    <div className="ratings-page">

      {/* Rating Summary */}
      <div className="ratings-summary">

        <div className="rating-score">
          <div className="score">4.8</div>

          <div className="score-stars">
            ★ ★ ★ ★ <span>★</span>
          </div>

          <div className="review-count">
            127 reviews
          </div>
        </div>

        <div className="rating-breakdown">
          {ratingBreakdown.map((item) => (
            <div className="rating-row" key={item.stars}>

              <div className="rating-label">
                {item.stars} {item.stars === 1 ? 'star' : 'stars'}
              </div>

              <div className="rating-bar">
                <div
                  className="rating-bar-fill"
                  style={{ width: `${item.percentage}%` }}
                />
              </div>

              <div className="rating-percentage">
                {item.percentage}%
              </div>

            </div>
          ))}
        </div>

      </div>

      {/* Reviews */}
      <div className="reviews-list">

        {reviews.map((review) => (
          <div className="review-card" key={review.name}>

            <div className="review-header">
              <h3>{review.name}</h3>
              <span>{review.date}</span>
            </div>

            <div className="review-stars">
              {'★'.repeat(review.rating)}
              <span>
                {'★'.repeat(5 - review.rating)}
              </span>
            </div>

            <p>{review.comment}</p>

            <div className="review-tags">
              {review.tags.map((tag) => (
                <span key={tag}>{tag}</span>
              ))}
            </div>

          </div>
        ))}

      </div>

    </div>
  );
}

export default Ratings;