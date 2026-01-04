{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('media_insights') }}
),

renamed as (
    select
        id,
        cast(like_count as integer) as like_count,
        cast(reel_likes as integer) as reel_likes,
        cast(comment_count as integer) as comment_count,
        cast(reel_comments as integer) as reel_comments,
        cast(video_photo_saved as integer) as video_photo_saved,
        cast(carousel_album_saved as integer) as carousel_album_saved,
        cast(reel_saved as integer) as reel_saved,
        cast(video_photo_shares as integer) as video_photo_shares,
        cast(carousel_album_shares as integer) as carousel_album_shares,
        cast(reel_shares as integer) as reel_shares,
        cast(story_shares as integer) as story_shares,
        timestamp
    from source
)

select * from renamed
