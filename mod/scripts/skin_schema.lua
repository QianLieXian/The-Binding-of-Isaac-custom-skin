local schema = {}

schema.formatVersion = 2

schema.gridSize = 32

schema.canvasSize = 512

schema.groups = {
  {
    id = "head_idle",
    title = "头部静止 Head Idle",
    frames = {
      {
        id = "head_down_1",
        label = "头部向下 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadDown",
          frame = 0,
        },
      },
      {
        id = "head_down_2",
        label = "头部向下 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadDown",
          frame = 1,
        },
      },
      {
        id = "head_right_1",
        label = "头部向右 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadRight",
          frame = 0,
        },
      },
      {
        id = "head_right_2",
        label = "头部向右 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadRight",
          frame = 1,
        },
      },
      {
        id = "head_up_1",
        label = "头部向上 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadUp",
          frame = 0,
        },
      },
      {
        id = "head_up_2",
        label = "头部向上 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadUp",
          frame = 1,
        },
      },
      {
        id = "head_left_1",
        label = "头部向左 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadLeft",
          frame = 0,
        },
      },
      {
        id = "head_left_2",
        label = "头部向左 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadLeft",
          frame = 1,
        },
      },
    },
  },
  {
    id = "head_overlay",
    title = "头部覆盖层 Head Overlay",
    frames = {
      {
        id = "head_overlay_down_1",
        label = "覆盖层向下 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadDown_Overlay",
          frame = 0,
        },
      },
      {
        id = "head_overlay_down_2",
        label = "覆盖层向下 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadDown_Overlay",
          frame = 1,
        },
      },
      {
        id = "head_overlay_down_3",
        label = "覆盖层向下 · 帧 3",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadDown_Overlay",
          frame = 2,
        },
      },
      {
        id = "head_overlay_down_4",
        label = "覆盖层向下 · 帧 4",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadDown_Overlay",
          frame = 3,
        },
      },
      {
        id = "head_overlay_right_1",
        label = "覆盖层向右 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadRight_Overlay",
          frame = 0,
        },
      },
      {
        id = "head_overlay_right_2",
        label = "覆盖层向右 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadRight_Overlay",
          frame = 1,
        },
      },
      {
        id = "head_overlay_right_3",
        label = "覆盖层向右 · 帧 3",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadRight_Overlay",
          frame = 2,
        },
      },
      {
        id = "head_overlay_right_4",
        label = "覆盖层向右 · 帧 4",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadRight_Overlay",
          frame = 3,
        },
      },
      {
        id = "head_overlay_up_1",
        label = "覆盖层向上 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadUp_Overlay",
          frame = 0,
        },
      },
      {
        id = "head_overlay_up_2",
        label = "覆盖层向上 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadUp_Overlay",
          frame = 1,
        },
      },
      {
        id = "head_overlay_up_3",
        label = "覆盖层向上 · 帧 3",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadUp_Overlay",
          frame = 2,
        },
      },
      {
        id = "head_overlay_up_4",
        label = "覆盖层向上 · 帧 4",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadUp_Overlay",
          frame = 3,
        },
      },
      {
        id = "head_overlay_left_1",
        label = "覆盖层向左 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadLeft_Overlay",
          frame = 0,
        },
      },
      {
        id = "head_overlay_left_2",
        label = "覆盖层向左 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadLeft_Overlay",
          frame = 1,
        },
      },
      {
        id = "head_overlay_left_3",
        label = "覆盖层向左 · 帧 3",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadLeft_Overlay",
          frame = 2,
        },
      },
      {
        id = "head_overlay_left_4",
        label = "覆盖层向左 · 帧 4",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HeadLeft_Overlay",
          frame = 3,
        },
      },
    },
  },
  {
    id = "walk",
    title = "身体移动 Walk",
    frames = {
      {
        id = "walk_down_01",
        label = "身体向下移动 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 0,
        },
      },
      {
        id = "walk_down_02",
        label = "身体向下移动 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 1,
        },
      },
      {
        id = "walk_down_03",
        label = "身体向下移动 · 帧 3",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 2,
        },
      },
      {
        id = "walk_down_04",
        label = "身体向下移动 · 帧 4",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 3,
        },
      },
      {
        id = "walk_down_05",
        label = "身体向下移动 · 帧 5",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 4,
        },
      },
      {
        id = "walk_down_06",
        label = "身体向下移动 · 帧 6",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 5,
        },
      },
      {
        id = "walk_down_07",
        label = "身体向下移动 · 帧 7",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 6,
        },
      },
      {
        id = "walk_down_08",
        label = "身体向下移动 · 帧 8",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 7,
        },
      },
      {
        id = "walk_down_09",
        label = "身体向下移动 · 帧 9",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 8,
        },
      },
      {
        id = "walk_down_10",
        label = "身体向下移动 · 帧 10",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkDown",
          frame = 9,
        },
      },
      {
        id = "walk_right_01",
        label = "身体向右移动 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 0,
        },
      },
      {
        id = "walk_right_02",
        label = "身体向右移动 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 1,
        },
      },
      {
        id = "walk_right_03",
        label = "身体向右移动 · 帧 3",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 2,
        },
      },
      {
        id = "walk_right_04",
        label = "身体向右移动 · 帧 4",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 3,
        },
      },
      {
        id = "walk_right_05",
        label = "身体向右移动 · 帧 5",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 4,
        },
      },
      {
        id = "walk_right_06",
        label = "身体向右移动 · 帧 6",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 5,
        },
      },
      {
        id = "walk_right_07",
        label = "身体向右移动 · 帧 7",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 6,
        },
      },
      {
        id = "walk_right_08",
        label = "身体向右移动 · 帧 8",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 7,
        },
      },
      {
        id = "walk_right_09",
        label = "身体向右移动 · 帧 9",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 8,
        },
      },
      {
        id = "walk_right_10",
        label = "身体向右移动 · 帧 10",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkRight",
          frame = 9,
        },
      },
      {
        id = "walk_up_01",
        label = "身体向上移动 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 0,
        },
      },
      {
        id = "walk_up_02",
        label = "身体向上移动 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 1,
        },
      },
      {
        id = "walk_up_03",
        label = "身体向上移动 · 帧 3",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 2,
        },
      },
      {
        id = "walk_up_04",
        label = "身体向上移动 · 帧 4",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 3,
        },
      },
      {
        id = "walk_up_05",
        label = "身体向上移动 · 帧 5",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 4,
        },
      },
      {
        id = "walk_up_06",
        label = "身体向上移动 · 帧 6",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 5,
        },
      },
      {
        id = "walk_up_07",
        label = "身体向上移动 · 帧 7",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 6,
        },
      },
      {
        id = "walk_up_08",
        label = "身体向上移动 · 帧 8",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 7,
        },
      },
      {
        id = "walk_up_09",
        label = "身体向上移动 · 帧 9",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 8,
        },
      },
      {
        id = "walk_up_10",
        label = "身体向上移动 · 帧 10",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkUp",
          frame = 9,
        },
      },
      {
        id = "walk_left_01",
        label = "身体向左移动 · 帧 1",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 0,
        },
      },
      {
        id = "walk_left_02",
        label = "身体向左移动 · 帧 2",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 1,
        },
      },
      {
        id = "walk_left_03",
        label = "身体向左移动 · 帧 3",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 2,
        },
      },
      {
        id = "walk_left_04",
        label = "身体向左移动 · 帧 4",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 3,
        },
      },
      {
        id = "walk_left_05",
        label = "身体向左移动 · 帧 5",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 4,
        },
      },
      {
        id = "walk_left_06",
        label = "身体向左移动 · 帧 6",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 5,
        },
      },
      {
        id = "walk_left_07",
        label = "身体向左移动 · 帧 7",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 6,
        },
      },
      {
        id = "walk_left_08",
        label = "身体向左移动 · 帧 8",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 7,
        },
      },
      {
        id = "walk_left_09",
        label = "身体向左移动 · 帧 9",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 8,
        },
      },
      {
        id = "walk_left_10",
        label = "身体向左移动 · 帧 10",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "WalkLeft",
          frame = 9,
        },
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
        anm2 = {
          file = "001.000_player.anm2",
          animation = "ShootDown",
          frame = 0,
        },
      },
      {
        id = "shoot_right",
        label = "射击 · 面向右",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "ShootRight",
          frame = 0,
        },
      },
      {
        id = "shoot_up",
        label = "射击 · 面向上",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "ShootUp",
          frame = 0,
        },
      },
      {
        id = "shoot_left",
        label = "射击 · 面向左",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "ShootLeft",
          frame = 0,
        },
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
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HurtDown",
          frame = 0,
        },
      },
      {
        id = "hurt_right",
        label = "受伤 · 面向右",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HurtRight",
          frame = 0,
        },
      },
      {
        id = "hurt_up",
        label = "受伤 · 面向上",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HurtUp",
          frame = 0,
        },
      },
      {
        id = "hurt_left",
        label = "受伤 · 面向左",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "HurtLeft",
          frame = 0,
        },
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
        anm2 = {
          file = "001.000_player.anm2",
          animation = "UseItem",
          frame = 0,
        },
      },
      {
        id = "item_charge",
        label = "主动道具蓄力",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "UseItemHold",
          frame = 0,
        },
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
        anm2 = {
          file = "001.000_player.anm2",
          animation = "Jump",
          frame = 0,
        },
      },
      {
        id = "jump_land",
        label = "跳跃落地",
        anm2 = {
          file = "001.000_player.anm2",
          animation = "JumpDown",
          frame = 0,
        },
      },
    },
  },
  {
    id = "cosmetics",
    title = "装扮 Cosmetics",
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
  "head_down_1",
  "head_down_2",
  "head_right_1",
  "head_right_2",
  "head_up_1",
  "head_up_2",
  "head_left_1",
  "head_left_2",
  "head_overlay_down_1",
  "head_overlay_down_2",
  "head_overlay_down_3",
  "head_overlay_down_4",
  "head_overlay_right_1",
  "head_overlay_right_2",
  "head_overlay_right_3",
  "head_overlay_right_4",
  "head_overlay_up_1",
  "head_overlay_up_2",
  "head_overlay_up_3",
  "head_overlay_up_4",
  "head_overlay_left_1",
  "head_overlay_left_2",
  "head_overlay_left_3",
  "head_overlay_left_4",
  "walk_down_01",
  "walk_down_02",
  "walk_down_03",
  "walk_down_04",
  "walk_down_05",
  "walk_down_06",
  "walk_down_07",
  "walk_down_08",
  "walk_down_09",
  "walk_down_10",
  "walk_right_01",
  "walk_right_02",
  "walk_right_03",
  "walk_right_04",
  "walk_right_05",
  "walk_right_06",
  "walk_right_07",
  "walk_right_08",
  "walk_right_09",
  "walk_right_10",
  "walk_up_01",
  "walk_up_02",
  "walk_up_03",
  "walk_up_04",
  "walk_up_05",
  "walk_up_06",
  "walk_up_07",
  "walk_up_08",
  "walk_up_09",
  "walk_up_10",
  "walk_left_01",
  "walk_left_02",
  "walk_left_03",
  "walk_left_04",
  "walk_left_05",
  "walk_left_06",
  "walk_left_07",
  "walk_left_08",
  "walk_left_09",
  "walk_left_10",
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
      "head_down_1",
    },
    targets = {
      "head_down_2",
    },
    removeSource = False,
  },
  {
    sources = {
      "head_right_1",
    },
    targets = {
      "head_right_2",
    },
    removeSource = False,
  },
  {
    sources = {
      "head_up_1",
    },
    targets = {
      "head_up_2",
    },
    removeSource = False,
  },
  {
    sources = {
      "head_left_1",
    },
    targets = {
      "head_left_2",
    },
    removeSource = False,
  },
  {
    sources = {
      "head_overlay_down_1",
    },
    targets = {
      "head_overlay_down_2",
      "head_overlay_down_3",
      "head_overlay_down_4",
    },
    removeSource = False,
  },
  {
    sources = {
      "head_overlay_right_1",
    },
    targets = {
      "head_overlay_right_2",
      "head_overlay_right_3",
      "head_overlay_right_4",
    },
    removeSource = False,
  },
  {
    sources = {
      "head_overlay_up_1",
    },
    targets = {
      "head_overlay_up_2",
      "head_overlay_up_3",
      "head_overlay_up_4",
    },
    removeSource = False,
  },
  {
    sources = {
      "head_overlay_left_1",
    },
    targets = {
      "head_overlay_left_2",
      "head_overlay_left_3",
      "head_overlay_left_4",
    },
    removeSource = False,
  },
  {
    sources = {
      "walk_down_01",
    },
    targets = {
      "walk_down_02",
      "walk_down_03",
      "walk_down_04",
      "walk_down_05",
      "walk_down_06",
      "walk_down_07",
      "walk_down_08",
      "walk_down_09",
      "walk_down_10",
    },
    removeSource = False,
  },
  {
    sources = {
      "walk_right_01",
    },
    targets = {
      "walk_right_02",
      "walk_right_03",
      "walk_right_04",
      "walk_right_05",
      "walk_right_06",
      "walk_right_07",
      "walk_right_08",
      "walk_right_09",
      "walk_right_10",
    },
    removeSource = False,
  },
  {
    sources = {
      "walk_up_01",
    },
    targets = {
      "walk_up_02",
      "walk_up_03",
      "walk_up_04",
      "walk_up_05",
      "walk_up_06",
      "walk_up_07",
      "walk_up_08",
      "walk_up_09",
      "walk_up_10",
    },
    removeSource = False,
  },
  {
    sources = {
      "walk_left_01",
    },
    targets = {
      "walk_left_02",
      "walk_left_03",
      "walk_left_04",
      "walk_left_05",
      "walk_left_06",
      "walk_left_07",
      "walk_left_08",
      "walk_left_09",
      "walk_left_10",
    },
    removeSource = False,
  },
}

schema.frameLookup = {
  head_down_1 = {
    id = "head_down_1",
    label = "头部向下 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadDown",
      frame = 0,
    },
  },
  head_down_2 = {
    id = "head_down_2",
    label = "头部向下 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadDown",
      frame = 1,
    },
  },
  head_right_1 = {
    id = "head_right_1",
    label = "头部向右 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadRight",
      frame = 0,
    },
  },
  head_right_2 = {
    id = "head_right_2",
    label = "头部向右 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadRight",
      frame = 1,
    },
  },
  head_up_1 = {
    id = "head_up_1",
    label = "头部向上 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadUp",
      frame = 0,
    },
  },
  head_up_2 = {
    id = "head_up_2",
    label = "头部向上 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadUp",
      frame = 1,
    },
  },
  head_left_1 = {
    id = "head_left_1",
    label = "头部向左 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadLeft",
      frame = 0,
    },
  },
  head_left_2 = {
    id = "head_left_2",
    label = "头部向左 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadLeft",
      frame = 1,
    },
  },
  head_overlay_down_1 = {
    id = "head_overlay_down_1",
    label = "覆盖层向下 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadDown_Overlay",
      frame = 0,
    },
  },
  head_overlay_down_2 = {
    id = "head_overlay_down_2",
    label = "覆盖层向下 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadDown_Overlay",
      frame = 1,
    },
  },
  head_overlay_down_3 = {
    id = "head_overlay_down_3",
    label = "覆盖层向下 · 帧 3",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadDown_Overlay",
      frame = 2,
    },
  },
  head_overlay_down_4 = {
    id = "head_overlay_down_4",
    label = "覆盖层向下 · 帧 4",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadDown_Overlay",
      frame = 3,
    },
  },
  head_overlay_right_1 = {
    id = "head_overlay_right_1",
    label = "覆盖层向右 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadRight_Overlay",
      frame = 0,
    },
  },
  head_overlay_right_2 = {
    id = "head_overlay_right_2",
    label = "覆盖层向右 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadRight_Overlay",
      frame = 1,
    },
  },
  head_overlay_right_3 = {
    id = "head_overlay_right_3",
    label = "覆盖层向右 · 帧 3",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadRight_Overlay",
      frame = 2,
    },
  },
  head_overlay_right_4 = {
    id = "head_overlay_right_4",
    label = "覆盖层向右 · 帧 4",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadRight_Overlay",
      frame = 3,
    },
  },
  head_overlay_up_1 = {
    id = "head_overlay_up_1",
    label = "覆盖层向上 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadUp_Overlay",
      frame = 0,
    },
  },
  head_overlay_up_2 = {
    id = "head_overlay_up_2",
    label = "覆盖层向上 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadUp_Overlay",
      frame = 1,
    },
  },
  head_overlay_up_3 = {
    id = "head_overlay_up_3",
    label = "覆盖层向上 · 帧 3",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadUp_Overlay",
      frame = 2,
    },
  },
  head_overlay_up_4 = {
    id = "head_overlay_up_4",
    label = "覆盖层向上 · 帧 4",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadUp_Overlay",
      frame = 3,
    },
  },
  head_overlay_left_1 = {
    id = "head_overlay_left_1",
    label = "覆盖层向左 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadLeft_Overlay",
      frame = 0,
    },
  },
  head_overlay_left_2 = {
    id = "head_overlay_left_2",
    label = "覆盖层向左 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadLeft_Overlay",
      frame = 1,
    },
  },
  head_overlay_left_3 = {
    id = "head_overlay_left_3",
    label = "覆盖层向左 · 帧 3",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadLeft_Overlay",
      frame = 2,
    },
  },
  head_overlay_left_4 = {
    id = "head_overlay_left_4",
    label = "覆盖层向左 · 帧 4",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HeadLeft_Overlay",
      frame = 3,
    },
  },
  walk_down_01 = {
    id = "walk_down_01",
    label = "身体向下移动 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 0,
    },
  },
  walk_down_02 = {
    id = "walk_down_02",
    label = "身体向下移动 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 1,
    },
  },
  walk_down_03 = {
    id = "walk_down_03",
    label = "身体向下移动 · 帧 3",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 2,
    },
  },
  walk_down_04 = {
    id = "walk_down_04",
    label = "身体向下移动 · 帧 4",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 3,
    },
  },
  walk_down_05 = {
    id = "walk_down_05",
    label = "身体向下移动 · 帧 5",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 4,
    },
  },
  walk_down_06 = {
    id = "walk_down_06",
    label = "身体向下移动 · 帧 6",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 5,
    },
  },
  walk_down_07 = {
    id = "walk_down_07",
    label = "身体向下移动 · 帧 7",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 6,
    },
  },
  walk_down_08 = {
    id = "walk_down_08",
    label = "身体向下移动 · 帧 8",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 7,
    },
  },
  walk_down_09 = {
    id = "walk_down_09",
    label = "身体向下移动 · 帧 9",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 8,
    },
  },
  walk_down_10 = {
    id = "walk_down_10",
    label = "身体向下移动 · 帧 10",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkDown",
      frame = 9,
    },
  },
  walk_right_01 = {
    id = "walk_right_01",
    label = "身体向右移动 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 0,
    },
  },
  walk_right_02 = {
    id = "walk_right_02",
    label = "身体向右移动 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 1,
    },
  },
  walk_right_03 = {
    id = "walk_right_03",
    label = "身体向右移动 · 帧 3",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 2,
    },
  },
  walk_right_04 = {
    id = "walk_right_04",
    label = "身体向右移动 · 帧 4",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 3,
    },
  },
  walk_right_05 = {
    id = "walk_right_05",
    label = "身体向右移动 · 帧 5",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 4,
    },
  },
  walk_right_06 = {
    id = "walk_right_06",
    label = "身体向右移动 · 帧 6",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 5,
    },
  },
  walk_right_07 = {
    id = "walk_right_07",
    label = "身体向右移动 · 帧 7",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 6,
    },
  },
  walk_right_08 = {
    id = "walk_right_08",
    label = "身体向右移动 · 帧 8",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 7,
    },
  },
  walk_right_09 = {
    id = "walk_right_09",
    label = "身体向右移动 · 帧 9",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 8,
    },
  },
  walk_right_10 = {
    id = "walk_right_10",
    label = "身体向右移动 · 帧 10",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkRight",
      frame = 9,
    },
  },
  walk_up_01 = {
    id = "walk_up_01",
    label = "身体向上移动 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 0,
    },
  },
  walk_up_02 = {
    id = "walk_up_02",
    label = "身体向上移动 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 1,
    },
  },
  walk_up_03 = {
    id = "walk_up_03",
    label = "身体向上移动 · 帧 3",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 2,
    },
  },
  walk_up_04 = {
    id = "walk_up_04",
    label = "身体向上移动 · 帧 4",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 3,
    },
  },
  walk_up_05 = {
    id = "walk_up_05",
    label = "身体向上移动 · 帧 5",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 4,
    },
  },
  walk_up_06 = {
    id = "walk_up_06",
    label = "身体向上移动 · 帧 6",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 5,
    },
  },
  walk_up_07 = {
    id = "walk_up_07",
    label = "身体向上移动 · 帧 7",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 6,
    },
  },
  walk_up_08 = {
    id = "walk_up_08",
    label = "身体向上移动 · 帧 8",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 7,
    },
  },
  walk_up_09 = {
    id = "walk_up_09",
    label = "身体向上移动 · 帧 9",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 8,
    },
  },
  walk_up_10 = {
    id = "walk_up_10",
    label = "身体向上移动 · 帧 10",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkUp",
      frame = 9,
    },
  },
  walk_left_01 = {
    id = "walk_left_01",
    label = "身体向左移动 · 帧 1",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 0,
    },
  },
  walk_left_02 = {
    id = "walk_left_02",
    label = "身体向左移动 · 帧 2",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 1,
    },
  },
  walk_left_03 = {
    id = "walk_left_03",
    label = "身体向左移动 · 帧 3",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 2,
    },
  },
  walk_left_04 = {
    id = "walk_left_04",
    label = "身体向左移动 · 帧 4",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 3,
    },
  },
  walk_left_05 = {
    id = "walk_left_05",
    label = "身体向左移动 · 帧 5",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 4,
    },
  },
  walk_left_06 = {
    id = "walk_left_06",
    label = "身体向左移动 · 帧 6",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 5,
    },
  },
  walk_left_07 = {
    id = "walk_left_07",
    label = "身体向左移动 · 帧 7",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 6,
    },
  },
  walk_left_08 = {
    id = "walk_left_08",
    label = "身体向左移动 · 帧 8",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 7,
    },
  },
  walk_left_09 = {
    id = "walk_left_09",
    label = "身体向左移动 · 帧 9",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 8,
    },
  },
  walk_left_10 = {
    id = "walk_left_10",
    label = "身体向左移动 · 帧 10",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "WalkLeft",
      frame = 9,
    },
  },
  shoot_down = {
    id = "shoot_down",
    label = "射击 · 面向下",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "ShootDown",
      frame = 0,
    },
  },
  shoot_right = {
    id = "shoot_right",
    label = "射击 · 面向右",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "ShootRight",
      frame = 0,
    },
  },
  shoot_up = {
    id = "shoot_up",
    label = "射击 · 面向上",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "ShootUp",
      frame = 0,
    },
  },
  shoot_left = {
    id = "shoot_left",
    label = "射击 · 面向左",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "ShootLeft",
      frame = 0,
    },
  },
  hurt_down = {
    id = "hurt_down",
    label = "受伤 · 面向下",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HurtDown",
      frame = 0,
    },
  },
  hurt_right = {
    id = "hurt_right",
    label = "受伤 · 面向右",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HurtRight",
      frame = 0,
    },
  },
  hurt_up = {
    id = "hurt_up",
    label = "受伤 · 面向上",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HurtUp",
      frame = 0,
    },
  },
  hurt_left = {
    id = "hurt_left",
    label = "受伤 · 面向左",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "HurtLeft",
      frame = 0,
    },
  },
  item_use = {
    id = "item_use",
    label = "使用主动道具",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "UseItem",
      frame = 0,
    },
  },
  item_charge = {
    id = "item_charge",
    label = "主动道具蓄力",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "UseItemHold",
      frame = 0,
    },
  },
  jump_start = {
    id = "jump_start",
    label = "跳跃开始",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "Jump",
      frame = 0,
    },
  },
  jump_land = {
    id = "jump_land",
    label = "跳跃落地",
    anm2 = {
      file = "001.000_player.anm2",
      animation = "JumpDown",
      frame = 0,
    },
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
