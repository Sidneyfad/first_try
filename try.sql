select 
  *
  ,case when CommentScene_ = '76' then '附近直播tab' -----新版本口径CommentScene_='94'
        when CommentScene_ in ('80','94') then '附近更多推荐直播页面'
        when CommentScene_ = '16' then '视频tab_主播直播中'
        else 'other'
  end as CommentScene
  ,'unknown' as tab_id
  ,'unknown' as tab_type
  ,case when get_json_object(unbase64(SessionBuffer_), '$.recommend_system') in ('1009','4') then 'euler'
        when get_json_object(unbase64(SessionBuffer_), '$.recommend_system') in ('1') then 'metis'
        else 'other'
  end as recommend_system
from 
  wxg_weixin_analytics::t_ods_finder_broadcast_log21178_distinct_d
where 
  substr(ds,0,8)=${YYYYMMDD}
  and duration_<=36000000 -- 为了避免报成时间戳
  and uin_ != 0 and uin_ is not null and liveid_ is not null and liveid_ <> '' and liveid_ > '0'
  and CommentScene_ in ('16','76','80','94')----新版本口径CommentScene='94'
  and ((device_=2
      and clientversion_>=conv(27001634,16,10)
      and clientversion_<conv(28000000,16,10))
      or (device_=1 and clientversion_>=conv(17001422,16,10)
          and clientversion_<conv(18000023,16,10)))

union all

select 
  t1.*
  ,case when tab_id = '1' then '新闻'
        when tab_id='2' then '购物'
        when tab_id='3' then '日常生活'
        when tab_id='4' then '才艺'
        when tab_id='5' then '知识教培'
        when tab_id='6' then '游戏'
        when tab_id='10' then '颜值'
        when tab_id='88888' then '关注'
        when tab_id='88889' then '同城'
        when tab_id = '88890' then '朋友在看'
        when tab_id = '88891' then '颜值才艺'
        when tab_id = '7' then '试播'
        when tab_id = '8' then '内部秀场'
        when tab_id = '9' then '内部时政'
        else '其他'
  end as tab_type
  ,case when get_json_object(unbase64(SessionBuffer_), '$.recommend_system') in ('1009','4') then 'euler'
        when get_json_object(unbase64(SessionBuffer_), '$.recommend_system') in ('1') then 'metis'
        else 'other'
  end as recommend_system
from
  (
  select 
    *
    ,case when CommentScene_ = '94' then '附近直播'
          when CommentScene_ = '80' then '更多直播'
          else 'other_'
    end as CommentScene,
    get_json_object(unbase64(SessionBuffer_), '$.live_tab_id') as tab_id
  from 
    wxg_weixin_analytics::t_ods_finder_broadcast_log21178_distinct_d
  where 
    substr(ds,0,8)=${YYYYMMDD}
    and duration_<=36000000 -- 为了避免报成时间戳
    and uin_ != 0 and uin_ is not null and liveid_ is not null and liveid_ <> '' and liveid_ > '0'
    and  substr(CommentScene_,1,2) in ( '94','80') 
    and ((device_=2
    and clientversion_>=conv(28000000,16,10))
        or (device_=1 and clientversion_>=conv(18000023,16,10)))----修改版本号
  )t1 
