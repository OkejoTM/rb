json.id comment.id
json.message comment.message
json.author_name comment.author_name
json.created_at date_format(comment.created_at, format_type: :short_date_time_format)
