json.notice notice
json.comment do
  json.partial! 'admin/comments/comment', comment: comment
end
