export type FaqCategory = "product" | "learning" | "cooperation" | "privacy";

export type FaqItem = {
  id: string;
  category: FaqCategory;
  question: string;
  answer: string;
};

export const faqCategories: Array<{
  id: FaqCategory;
  label: string;
  description: string;
}> = [
  {
    id: "product",
    label: "产品与课程",
    description: "了解星鹿爱学的产品定位、课程内容与运行方式。"
  },
  {
    id: "learning",
    label: "学习与设备",
    description: "了解适用学段、学习方式和专用设备要求。"
  },
  {
    id: "cooperation",
    label: "合作与支持",
    description: "了解合作流程、费用构成、运营支持与获客边界。"
  },
  {
    id: "privacy",
    label: "数据与隐私",
    description: "了解学习数据、个人信息与权限管理原则。"
  }
];

export const faqItems: FaqItem[] = [
  {
    id: "what-is-xinglu",
    category: "product",
    question: "星鹿爱学是什么？它是如何运作的？",
    answer:
      "星鹿爱学是由北京银河智学教育科技有限公司研发的 AI 智能学习系统。核心团队具有腾讯、阿里巴巴、字节跳动等互联网企业的产品与技术经验，系统依托大模型能力，围绕“AI 授知识，真人伴成长”组织学习服务：AI 负责知识讲解、即时答疑、练习反馈与学习路径，真人老师专注学习动力、习惯培养、目标管理和个性化陪伴，帮助孩子逐步从被动完成任务走向主动学习。"
  },
  {
    id: "curriculum-sync",
    category: "product",
    question: "星鹿爱学的课程和学校教材同步吗？",
    answer:
      "课程覆盖人教版、苏教版、北师大版等全国主流教材版本，可结合校内学习进度安排学习与练习。具体学科、年级和教材版本以当前产品实际上线内容为准。"
  },
  {
    id: "supported-devices",
    category: "product",
    question: "学员可以用手机或其他平板学习吗？",
    answer:
      "正式的 AI 课程学习和伴学服务需要在星鹿爱学专用学习终端上完成，以保证学习体验、数据记录与系统运行的一致性。家长查看报告等功能以实际交付版本支持的终端为准。"
  },
  {
    id: "age-range",
    category: "learning",
    question: "星鹿爱学适合多大年龄段的孩子？",
    answer:
      "目前主要面向初中和高中阶段学生。小学课程及其他学段的开放范围，以最新产品版本和正式通知为准。建议在体验前结合孩子的年级、学科基础和学习目标进行适配评估。"
  },
  {
    id: "difference-from-tutoring",
    category: "learning",
    question: "星鹿爱学和传统辅导班有什么区别？",
    answer:
      "传统辅导班通常按照固定进度和统一内容组织教学，较难持续兼顾每个学生的节奏与知识缺口。星鹿爱学通过学习数据识别薄弱点并动态组织学习路径，同时由真人导学老师关注目标、习惯、情绪和复盘，兼顾个性化学习效率与教育过程中的陪伴。"
  },
  {
    id: "become-partner",
    category: "cooperation",
    question: "如何成为星鹿爱学的合作伙伴？具体流程是什么？",
    answer:
      "可以先通过产品体验和项目沟通了解实际学习流程，再结合所在城市、场地、团队与用户基础选择适合的合作方式。双方完成适配评估并确认合作意向后签署正式协议，逐鹿未来将协同开展产品培训、启动准备和运营支持。"
  },
  {
    id: "cooperation-cost",
    category: "cooperation",
    question: "合作费用是多少？有没有隐藏成本？",
    answer:
      "合作费用会根据合作方式、授权范围、设备配置和服务内容综合确定。相关费用、设备采购、结算方式和持续服务安排会在签约前统一说明，并以正式合作方案和协议为准，不设置未披露收费。"
  },
  {
    id: "headquarters-support",
    category: "cooperation",
    question: "合作后会提供哪些支持？",
    answer:
      "支持内容包括产品与销售培训、导学服务方法、日常运营流程、合规传播素材、招生运营工具、技术问题协同和阶段复盘。具体培训频次、服务方式与交付清单以对应合作方案为准。"
  },
  {
    id: "student-resources",
    category: "cooperation",
    question: "会帮忙对接学生资源吗？",
    answer:
      "合作伙伴需要结合自身区域与资源基础开展本地用户拓展。逐鹿未来提供产品资料、营销素材、运营方法和培训支持，帮助伙伴更有效地触达目标用户，但不承诺直接提供学生资源或固定经营结果。"
  },
  {
    id: "data-privacy",
    category: "privacy",
    question: "星鹿爱学如何保护用户的数据和隐私？",
    answer:
      "产品在数据处理过程中遵循功能必要、权限最小化和分类分级保护原则，围绕学习记录、账户信息和不同角色权限进行管理。个人信息的具体收集范围、使用目的、保存方式和用户权利，以产品隐私政策、用户协议及实际授权页面为准。"
  }
];

export function selectFaqs(ids: string[]) {
  return ids
    .map((id) => faqItems.find((item) => item.id === id))
    .filter((item): item is FaqItem => Boolean(item));
}
