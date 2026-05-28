import http from 'node:http';
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { createInterface } from 'node:readline';

/**
 * 百家号批量上传正文服务器
 *
 * 用法：
 *   node scripts/bjh_body_server.mjs --dir "百度百家号/第1卷" --port 8765
 *
 * 接口：
 *   GET /ch/{章号}          → 返回纯文本正文（已去标题行）
 *   GET /ch/{章号}/title    → 返回章节标题
 *   GET /ch/{章号}/raw      → 返回原始文件内容
 *   GET /health             → 健康检查 + 可用章号列表
 */

const args = process.argv.slice(2);
function argVal(flag) {
  const idx = args.indexOf(flag);
  return idx >= 0 ? args[idx + 1] : null;
}

const port = Number(argVal('--port')) || 8765;
const dirArg = argVal('--dir') || '百度百家号/第1卷';
const chaptersDir = path.resolve(process.cwd(), dirArg);

/** 从文件名提取章号，如 "1.1.36 标题.md" → 36 */
function extractChapterNum(filename) {
  const m = filename.match(/^1\.1\.(\d+)\b/);
  return m ? Number(m[1]) : null;
}

/** 读取文件并分离标题与正文 */
async function readChapter(chNum) {
  const files = await readdir(chaptersDir);
  const target = files.find(f => extractChapterNum(f) === chNum);
  if (!target) return null;

  const raw = await readFile(path.join(chaptersDir, target), 'utf8');
  const lines = raw.split(/\r?\n/);

  // 标题行：去掉 "# " 前缀或直接取第一行
  let titleLine = lines[0];
  titleLine = titleLine.replace(/^#\s*/, '').trim();

  // 正文：从第二行开始
  const body = lines.slice(1).join('\n').trim();

  return { title: titleLine, body, raw, filename: target };
}

function sendText(res, status, text) {
  const body = Buffer.from(text, 'utf8');
  res.writeHead(status, {
    'Content-Type': 'text/plain; charset=utf-8',
    'Content-Length': body.length,
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
  });
  res.end(body);
}

function sendJson(res, status, payload) {
  const body = JSON.stringify(payload, null, 2);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
    'Access-Control-Allow-Origin': '*',
  });
  res.end(body);
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
    });
    return res.end();
  }

  const url = new URL(req.url, `http://127.0.0.1:${port}`);

  if (url.pathname === '/health') {
    const files = await readdir(chaptersDir);
    const chapters = files
      .map(f => extractChapterNum(f))
      .filter(Boolean)
      .sort((a, b) => a - b);
    return sendJson(res, 200, {
      ok: true,
      dir: chaptersDir,
      fileCount: files.length,
      chapters,
    });
  }

  // /ch/{num}
  const chMatch = url.pathname.match(/^\/ch\/(\d+)(\/\w+)?$/);
  if (!chMatch) {
    return sendJson(res, 404, { error: 'not_found', usage: '/ch/{num} → body, /ch/{num}/title, /ch/{num}/raw, /health' });
  }

  const chNum = Number(chMatch[1]);
  const sub = chMatch[2]?.replace('/', '') || 'body';

  try {
    const chapter = await readChapter(chNum);
    if (!chapter) {
      return sendJson(res, 404, { error: 'chapter_not_found', chapter: chNum });
    }

    switch (sub) {
      case 'title':
        return sendText(res, 200, chapter.title);
      case 'raw':
        return sendText(res, 200, chapter.raw);
      case 'body':
      default:
        return sendText(res, 200, chapter.body);
    }
  } catch (err) {
    return sendJson(res, 500, { error: 'read_failed', message: err.message });
  }
});

server.listen(port, '127.0.0.1', () => {
  console.log(`bjh-body-server: http://127.0.0.1:${port}`);
  console.log(`chapters dir: ${chaptersDir}`);
});
