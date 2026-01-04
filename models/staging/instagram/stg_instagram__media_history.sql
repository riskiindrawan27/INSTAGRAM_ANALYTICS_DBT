{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('media_history') }}
),

renamed as (
    select
        id,
        user_id,
        is_story,
        carousel_album_id,
        media_type,
        media_product_type,
        strptime(created_time, '%Y-%m-%d %H:%M:%S.%f Z') + interval '7 hours' as created_time
    from source
)

select * from renamed
