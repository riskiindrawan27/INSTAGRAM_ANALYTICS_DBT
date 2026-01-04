{{
    config(
        materialized='view'
    )
}}

with media_history as (
    select * from {{ ref('stg_instagram__media_history') }}
),

media_insights as (
    select * from {{ ref('stg_instagram__media_insights') }}
),
latest_insights as (
    select
        id,
        like_count,
        reel_likes,
        comment_count,
        reel_comments,
        video_photo_saved,
        carousel_album_saved,
        reel_saved,
        video_photo_shares,
        carousel_album_shares,
        reel_shares,
        story_shares,
        timestamp,
        row_number() over (partition by id order by timestamp desc) as rn
    from media_insights
),
previous_insights as (
    select
        id,
        like_count as prev_like_count,
        reel_likes as prev_reel_likes,
        comment_count as prev_comment_count,
        reel_comments as prev_reel_comments,
        video_photo_saved as prev_video_photo_saved,
        carousel_album_saved as prev_carousel_album_saved,
        reel_saved as prev_reel_saved,
        video_photo_shares as prev_video_photo_shares,
        carousel_album_shares as prev_carousel_album_shares,
        reel_shares as prev_reel_shares,
        story_shares as prev_story_shares,
        timestamp,
        row_number() over (partition by id order by timestamp desc) as rn
    from media_insights
),

joined as (
    select
        mh.id,
        mh.created_time,
        mh.user_id,
        mh.media_type,
        mh.media_product_type,
        coalesce(li.like_count, 0) as current_like_count,
        coalesce(li.reel_likes, 0) as current_reel_likes,
        coalesce(li.comment_count, 0) as current_comment_count,
        coalesce(li.reel_comments, 0) as current_reel_comments,
        coalesce(li.video_photo_saved, 0) as current_video_photo_saved,
        coalesce(li.carousel_album_saved, 0) as current_carousel_album_saved,
        coalesce(li.reel_saved, 0) as current_reel_saved,
        coalesce(li.video_photo_shares, 0) as current_video_photo_shares,
        coalesce(li.carousel_album_shares, 0) as current_carousel_album_shares,
        coalesce(li.reel_shares, 0) as current_reel_shares,
        coalesce(li.story_shares, 0) as current_story_shares,
        coalesce(pi.prev_like_count, 0) as prev_like_count,
        coalesce(pi.prev_reel_likes, 0) as prev_reel_likes,
        coalesce(pi.prev_comment_count, 0) as prev_comment_count,
        coalesce(pi.prev_reel_comments, 0) as prev_reel_comments,
        coalesce(pi.prev_video_photo_saved, 0) as prev_video_photo_saved,
        coalesce(pi.prev_carousel_album_saved, 0) as prev_carousel_album_saved,
        coalesce(pi.prev_reel_saved, 0) as prev_reel_saved,
        coalesce(pi.prev_video_photo_shares, 0) as prev_video_photo_shares,
        coalesce(pi.prev_carousel_album_shares, 0) as prev_carousel_album_shares,
        coalesce(pi.prev_reel_shares, 0) as prev_reel_shares,
        coalesce(pi.prev_story_shares, 0) as prev_story_shares
        
    from media_history mh
    left join latest_insights li
        on mh.id = li.id
        and li.rn = 1
    left join previous_insights pi
        on mh.id = pi.id
        and pi.rn = 2
)

select * from joined
