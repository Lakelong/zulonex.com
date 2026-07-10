export const site = {
  name: "逐鹿未来",
  fullName: "安徽逐鹿未来智能科技有限公司",
  domain: "zulonex.com",
  title: "逐鹿未来 | 星鹿爱学 AI教育运营服务",
  description:
    "逐鹿未来连接星鹿爱学产品与国内市场，提供合作拓展、运营培训与落地支持。",
  keywords:
    "逐鹿未来, 星鹿爱学, 小鹿爱学, 银河智学, AI智能伴学, AI教育运营, 自习室AI学习系统, AI原生学习系统",
  email: "contact@zulonex.com",
  phone: "",
  icp: "",
  address: "安徽省合肥市蜀山区中国声谷 5 号楼",
  tagline: "重塑学习 逐鹿未来",
  businessLoginUrl: import.meta.env.PUBLIC_BUSINESS_LOGIN_URL ?? "https://boss.zulonex.com",
  nav: [
    { href: "/product/", label: "星鹿爱学" },
    { href: "/solutions/", label: "解决方案" },
    { href: "/cooperation/", label: "合作支持" },
    { href: "/about/", label: "关于我们" }
  ],
  footerNav: [
    { href: "/project/", label: "项目介绍" },
    { href: "/insights/", label: "案例与洞察" },
    { href: "/faq/", label: "常见问题" },
    { href: "/login/", label: "商家工作台" },
    { href: "/contact/", label: "预约演示" }
  ]
};

export const solutionAudiences = [
  {
    id: "learning-space",
    icon: "Building2",
    label: "自主学习空间",
    text: "把 AI 学习、真人导学和家长反馈变成日常服务。"
  },
  {
    id: "training-transformation",
    icon: "School",
    label: "教培机构转型",
    text: "在原有团队和用户基础上验证 AI 学习服务。"
  },
  {
    id: "care-center",
    icon: "House",
    label: "托管与成长中心",
    text: "从作业看护延伸到诊断、习惯和反馈。"
  },
  {
    id: "regional-channel",
    icon: "MapPinned",
    label: "区域渠道伙伴",
    text: "结合本地资源开展推广、服务与运营协同。"
  }
];

export const relationship = [
  {
    role: "研发方",
    name: "银河智学",
    text: "提供星鹿爱学产品与教育大模型能力。"
  },
  {
    role: "产品",
    name: "星鹿爱学",
    text: "面向自主学习空间的 AI 智能伴学产品。"
  },
  {
    role: "运营销售方",
    name: "逐鹿未来",
    text: "负责合作拓展、市场运营与落地服务。"
  }
];

export const productModules = [
  {
    title: "AI 原生课程架构",
    description:
      "以动态文档、语音讲解、互动组件、AI 问答和学习数据构成课程系统。"
  },
  {
    title: "学科地图与学习路径",
    description:
      "可视化章节、知识点和进度，让学生知道自己在哪、下一步学什么。"
  },
  {
    title: "AI 问一问",
    description:
      "嵌入课程上下文的问答入口，支持追问、换方式讲解，并通过问题预判降低学生提问门槛。"
  },
  {
    title: "掌握度圆环",
    description:
      "基于学习与练习表现呈现掌握状态，让进步被看见。"
  },
  {
    title: "自适应练习与错题闭环",
    description:
      "围绕薄弱点推题巩固，串联错题入库、订正和再练习。"
  },
  {
    title: "家长端学情报告",
    description:
      "用阶段报告说明学会了什么、进步在哪里、下一步怎么安排。"
  }
];

export const servicePillars = [
  {
    title: "产品授权与场景导入",
    text: "围绕自习室、托管、教培转型等场景，提供演示与导入建议。"
  },
  {
    title: "标准化运营支持",
    text: "提供合作流程、服务节奏、导学方法和家长沟通支持。"
  },
  {
    title: "三端人机协同导学",
    text: "以 AI 系统、真人导学和家长报告形成服务闭环。"
  },
  {
    title: "市场与培训赋能",
    text: "提供合规素材、产品培训、销售答疑与运营复盘。"
  }
];

export const partnerTypes = [
  "线下自习室与共享学习空间",
  "托管班、素质成长中心与社区学习中心",
  "寻求 AI 教育转型的教培机构",
  "具备本地教育资源的区域渠道伙伴",
  "面向家庭自主学习场景的服务团队"
];

export const process = [
  "预约演示",
  "评估城市、场地、团队与用户基础",
  "完成培训与启动准备",
  "试运行并优化服务节奏",
  "持续复盘数据与反馈"
];
