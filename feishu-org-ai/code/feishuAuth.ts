/**
 * 飞书网页免登工具
 *
 * 来源：团队私有仓库 web/src/utils/feishuAuth.ts，该文件 59 行全部由本人在该项目中编写。
 * 本副本仅做脱敏：飞书应用 ID 替换为占位符，其余逻辑与原文件一致。
 */

/** 脱敏：正式环境由构建配置注入，不写入代码 */
const FEISHU_APP_ID = "cli_xxxxxxxxxxxxxxxx";

declare global {
  interface Window {
    h5sdk: any;
  }
}

export interface FeishuUser {
  openId: string;
  name: string;
  memberId: string;
}

/**
 * 在飞书客户端内自动完成登录，获取当前用户身份
 * 本地开发时返回测试用户身份
 */
export async function getCurrentFeishuUser(): Promise<FeishuUser> {
  // 本地开发环境返回测试用户
  if (window.location.hostname === "127.0.0.1" || window.location.hostname === "localhost") {
    return {
      openId: "test_open_id_001",
      name: "测试用户",
      memberId: "member-001",
    };
  }

  // 飞书客户端内自动获取授权码
  try {
    const authCode = await new Promise<string>((resolve, reject) => {
      window.h5sdk.call("requestAuthCode", {
        appId: FEISHU_APP_ID,
        success: (res: any) => resolve(res.code),
        fail: (err: any) => reject(err),
      });
    });

    // 拿授权码去后端换用户信息（身份校验在服务端完成）
    const res = await fetch(`/v1/feishu/auth/userinfo?code=${authCode}`);
    if (!res.ok) throw new Error("获取用户信息失败");
    const userInfo = await res.json();
    return {
      openId: userInfo.open_id,
      name: userInfo.name,
      memberId: userInfo.member_id,
    };
  } catch (e) {
    console.warn("飞书登录失败，降级为本地测试用户", e);
    return {
      openId: "test_open_id_001",
      name: "测试用户",
      memberId: "member-001",
    };
  }
}
