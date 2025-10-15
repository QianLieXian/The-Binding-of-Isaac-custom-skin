local schema = {}

schema.formatVersion = 2

schema.gridSize = 32

schema.canvasSize = 512

schema.groups = {
  {
    id = "idle",
    title = "静止 Idle",
    frames = {
      {
        id = "idle_down",
        label = "静止 · 面向下",
      },
      {
        id = "idle_right",
        label = "静止 · 面向右",
      },
      {
        id = "idle_up",
        label = "静止 · 面向上",
      },
      {
        id = "idle_left",
        label = "静止 · 面向左",
      },
    },
  },
  {
    id = "walk",
    title = "移动 Walk",
    frames = {
      {
        id = "walk_down",
        label = "移动 · 面向下",
      },
      {
        id = "walk_right",
        label = "移动 · 面向右",
      },
      {
        id = "walk_up",
        label = "移动 · 面向上",
      },
      {
        id = "walk_left",
        label = "移动 · 面向左",
      },
    },
  },
  {
    id = "shoot",
    title = "射击 Shoot",
    frames = {
      {
        id = "shoot_down",
        label = "射击 · 面向下",
      },
      {
        id = "shoot_right",
        label = "射击 · 面向右",
      },
      {
        id = "shoot_up",
        label = "射击 · 面向上",
      },
      {
        id = "shoot_left",
        label = "射击 · 面向左",
      },
    },
  },
  {
    id = "hurt",
    title = "受伤 Hurt",
    frames = {
      {
        id = "hurt_down",
        label = "受伤 · 面向下",
      },
      {
        id = "hurt_right",
        label = "受伤 · 面向右",
      },
      {
        id = "hurt_up",
        label = "受伤 · 面向上",
      },
      {
        id = "hurt_left",
        label = "受伤 · 面向左",
      },
    },
  },
  {
    id = "item",
    title = "使用道具 Item",
    frames = {
      {
        id = "item_use",
        label = "使用主动道具",
      },
      {
        id = "item_charge",
        label = "主动道具蓄力",
      },
    },
  },
  {
    id = "jump",
    title = "跳跃 Jump",
    frames = {
      {
        id = "jump_start",
        label = "跳跃开始",
      },
      {
        id = "jump_land",
        label = "落地",
      },
    },
  },
  {
    id = "cosmetics",
    title = "道具装扮 Cosmetics",
    frames = {
      {
        id = "item_hat",
        label = "头部装扮",
      },
      {
        id = "item_body",
        label = "身体装扮",
      },
    },
  },
}

schema.requiredFrames = {
  "idle_down",
  "idle_right",
  "idle_up",
  "idle_left",
  "walk_down",
  "walk_right",
  "walk_up",
  "walk_left",
  "shoot_down",
  "shoot_right",
  "shoot_up",
  "shoot_left",
  "hurt_down",
  "hurt_right",
  "hurt_up",
  "hurt_left",
  "item_use",
  "item_charge",
  "jump_start",
  "jump_land",
  "item_hat",
  "item_body",
}

schema.aliasRules = {
  {
    sources = {
      "move_down",
    },
    targets = {
      "walk_down",
    },
  },
  {
    sources = {
      "move_right",
    },
    targets = {
      "walk_right",
    },
  },
  {
    sources = {
      "move_up",
    },
    targets = {
      "walk_up",
    },
  },
  {
    sources = {
      "move_left",
    },
    targets = {
      "walk_left",
    },
  },
  {
    sources = {
      "hurt_side",
    },
    targets = {
      "hurt_left",
      "hurt_right",
    },
  },
}

schema.frameLookup = {
  idle_down = {
    id = "idle_down",
    label = "静止 · 面向下",
  },
  idle_right = {
    id = "idle_right",
    label = "静止 · 面向右",
  },
  idle_up = {
    id = "idle_up",
    label = "静止 · 面向上",
  },
  idle_left = {
    id = "idle_left",
    label = "静止 · 面向左",
  },
  walk_down = {
    id = "walk_down",
    label = "移动 · 面向下",
  },
  walk_right = {
    id = "walk_right",
    label = "移动 · 面向右",
  },
  walk_up = {
    id = "walk_up",
    label = "移动 · 面向上",
  },
  walk_left = {
    id = "walk_left",
    label = "移动 · 面向左",
  },
  shoot_down = {
    id = "shoot_down",
    label = "射击 · 面向下",
  },
  shoot_right = {
    id = "shoot_right",
    label = "射击 · 面向右",
  },
  shoot_up = {
    id = "shoot_up",
    label = "射击 · 面向上",
  },
  shoot_left = {
    id = "shoot_left",
    label = "射击 · 面向左",
  },
  hurt_down = {
    id = "hurt_down",
    label = "受伤 · 面向下",
  },
  hurt_right = {
    id = "hurt_right",
    label = "受伤 · 面向右",
  },
  hurt_up = {
    id = "hurt_up",
    label = "受伤 · 面向上",
  },
  hurt_left = {
    id = "hurt_left",
    label = "受伤 · 面向左",
  },
  item_use = {
    id = "item_use",
    label = "使用主动道具",
  },
  item_charge = {
    id = "item_charge",
    label = "主动道具蓄力",
  },
  jump_start = {
    id = "jump_start",
    label = "跳跃开始",
  },
  jump_land = {
    id = "jump_land",
    label = "落地",
  },
  item_hat = {
    id = "item_hat",
    label = "头部装扮",
  },
  item_body = {
    id = "item_body",
    label = "身体装扮",
  },
}

return schema
