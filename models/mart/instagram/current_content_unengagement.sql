{{
    config(
        materialized='table'
    )
}}

with engagement as (
    select * from {{ ref('int_instagram__media_engagement') }}
),

unengagement_calculated as (
    select
        id,
        created_time,
        user_id,
        media_type,
        media_product_type,
        
        -- Calculate unengagements based on media type and product type
        -- Unengagements = decrease in likes + decrease in saves + decrease in comments + decrease in shares
        case
            -- For REELS
            when media_product_type = 'REELS' then
                greatest(0, prev_reel_likes - current_reel_likes) +
                greatest(0, prev_reel_saved - current_reel_saved) +
                greatest(0, prev_reel_comments - current_reel_comments) +
                greatest(0, prev_reel_shares - current_reel_shares)
            
            -- For CAROUSEL_ALBUM (FEED)
            when media_type = 'CAROUSEL_ALBUM' then
                greatest(0, prev_like_count - current_like_count) +
                greatest(0, prev_carousel_album_saved - current_carousel_album_saved) +
                greatest(0, prev_comment_count - current_comment_count) +
                greatest(0, prev_carousel_album_shares - current_carousel_album_shares)
            
            -- For VIDEO/IMAGE (FEED)
            when media_product_type = 'FEED' or (media_type in ('VIDEO', 'IMAGE') and media_product_type is null) then
                greatest(0, prev_like_count - current_like_count) +
                greatest(0, prev_video_photo_saved - current_video_photo_saved) +
                greatest(0, prev_comment_count - current_comment_count) +
                greatest(0, prev_video_photo_shares - current_video_photo_shares)
            
            -- For STORY
            when media_product_type = 'STORY' then
                greatest(0, prev_story_shares - current_story_shares)
            
            else 0
        end as unengagements
        
    from engagement
)

select
    id,
    created_time,
    user_id,
    media_type,
    media_product_type,
    unengagements
from unengagement_calculated
where id is not null
order by created_time desc, id
