--[[
    A script that allows you to set different font for subtitles based on
    their languages.

    Currently, both Simplified Chinese and Traditional Chinese, Japanese are
    support, with LGC script (which covers a lot of languages using Latin,
    Greek and Cyrillic alphabets) used as a fallback.

    Note that, this script will only work for SRT subtitles and ASS subtitles
    without explicit Font styles. Also it does not work for the secondary
    subtitle.
--]]

local msg = require 'mp.msg'

local CURRENT_SUB_TRACK_LANG_PROPERTY = 'current-tracks/sub/lang'
local CURRENT_SUB_LANG = ''

-- Default values are used when the fonts in the config file cannot be resolved.
local options = {
    lgc = 'Arial',
    simplified_han = 'SimHei',
    traditional_han = 'DFKai-SB',
    japanese = 'MS Gothic',
}

-- Manually supply the kebab-case of the name of the script
require 'mp.options'.read_options(options, 'adaptive-sub-fonts')

-- Returns the font to use for the current selected subtitle track
-- Note that LGC is used as a fallback
local function get_font_to_use(lang)
    if (lang == 'zh-CN' or lang == 'sc' or
            lang == 'zh-Hans' or lang == 'zh-SG') then
        -- Chinese (Simplified)
        return options.simplified_han
    elseif (lang == 'zh-TW' or lang == 'tc' or lang == 'zh-HK' or
            lang == 'zh-MO' or lang == 'zh-Hant') then
        -- Chinese (Traditional)
        return options.traditional_han
    elseif (lang == 'ja' or lang == 'ja-JP' or lang == 'jpn') then
        -- Japanese
        return options.japanese
    end

    return options.lgc
end

-- Set the `sub-font` option
local function set_sub_font(font_name)
    mp.set_property('sub-font', font_name)
end

-- Obtain language info from the initial subtitle track
local function on_file_loaded()
    CURRENT_SUB_LANG = mp.get_property(CURRENT_SUB_TRACK_LANG_PROPERTY)

    msg.log('debug', CURRENT_SUB_LANG)

    local font_to_use = get_font_to_use(CURRENT_SUB_LANG)

    msg.log('debug', 'Setting subtitle font...')
    set_sub_font(font_to_use)
end

-- Watch the current selected subtitle track and set font accordingly
local function on_current_sub_lang_changed(name)
    CURRENT_SUB_LANG = mp.get_property(name)

    msg.log('debug', CURRENT_SUB_LANG)

    local font_to_use = get_font_to_use(CURRENT_SUB_LANG)

    msg.log('debug', 'Setting subtitle font...')
    set_sub_font(font_to_use)
end

mp.register_event('file-loaded', on_file_loaded)
mp.observe_property(CURRENT_SUB_TRACK_LANG_PROPERTY, 'string',
    on_current_sub_lang_changed)
