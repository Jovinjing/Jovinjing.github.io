<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { projects } from '../data/projects'

const route = useRoute()
const router = useRouter()

const project = computed(() => {
  return projects.find((p) => p.id === route.params.id)
})

const currentIndex = ref(0)
const slideDirection = ref<'left' | 'right'>('right')
const videoVisible = ref(false)

function goBack() {
  router.push({ name: 'home' })
}

function prev() {
  if (!project.value) return
  slideDirection.value = 'left'
  currentIndex.value = currentIndex.value > 0 ? currentIndex.value - 1 : project.value.images.length - 1
}

function next() {
  if (!project.value) return
  slideDirection.value = 'right'
  currentIndex.value = currentIndex.value < project.value.images.length - 1 ? currentIndex.value + 1 : 0
}

function goToImg(i: number) {
  slideDirection.value = i > currentIndex.value ? 'right' : 'left'
  currentIndex.value = i
}

function scrollTo(sectionId: string) {
  const el = document.getElementById(sectionId)
  if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

function openGithub() {
  if (project.value?.githubUrl) window.open(project.value.githubUrl, '_blank')
}

function playVideo() {
  videoVisible.value = true
  setTimeout(() => {
    const el = document.getElementById('demo-video')
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }, 100)
}

// 缩略图列数（保留给将来可能的 grid 布局用）
// const columns = computed(() => {
//   const n = project.value?.images.length ?? 0
//   return Math.min(n, 4)
// })
</script>

<template>
  <main v-if="project" class="min-h-screen bg-gradient-to-b from-sky-50 to-blue-50">
    <!-- 顶部导航条 -->
    <div class="sticky top-0 z-40 bg-white/70 backdrop-blur-lg border-b border-sky-200/40">
      <div class="max-w-4xl mx-auto px-4 py-3 flex items-center gap-3">
        <button
          class="flex items-center gap-1.5 text-sm text-slate-500 hover:text-sky-600 transition-colors cursor-pointer"
          @click="goBack"
        >
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
          </svg>
          返回
        </button>
        <span class="text-slate-300">/</span>
        <h1 class="text-sm font-bold text-slate-800 truncate">{{ project.title }}</h1>
      </div>
    </div>

    <div class="max-w-4xl mx-auto px-4 py-8">
      <!-- 标题区 -->
      <div class="mb-8">
        <div class="flex flex-wrap gap-2 mb-4">
          <span
            v-for="tech in project.techStack"
            :key="tech"
            class="text-xs px-3 py-1 rounded-full bg-sky-100/80 text-sky-700 font-medium border border-sky-200/50"
          >
            {{ tech }}
          </span>
        </div>
        <p class="text-lg text-slate-600 leading-relaxed">{{ project.tagline }}</p>
      </div>

      <!-- ========== 图片滑动轮播 ========== -->
      <div v-if="project.images.length > 0" class="mb-8 select-none">
        <!-- 主图滑轨 -->
        <div class="relative rounded-xl border border-sky-200/50 overflow-hidden bg-gradient-to-b from-white/90 to-white/70 group shadow-[0_2px_8px_rgba(0,0,0,0.04),0_8px_24px_rgba(0,0,0,0.06)]">
          <!-- 滑动容器 -->
          <div class="relative w-full overflow-hidden" style="aspect-ratio: 16 / 10;">
            <div
              v-for="(img, i) in project.images"
              :key="i"
              class="absolute inset-0 w-full h-full transition-transform duration-400 ease-[cubic-bezier(0.25,0.46,0.45,0.94)]"
              :class="{
                'opacity-100': i === currentIndex,
                'opacity-0': i !== currentIndex,
              }"
              :style="{
                transform: i === currentIndex ? 'translateX(0)' : (i < currentIndex ? 'translateX(-100%)' : 'translateX(100%)'),
              }"
            >
              <img
                :src="img"
                :alt="`${project.title} 截图 ${i + 1}`"
                class="w-full h-full object-contain bg-sky-50 transition-transform duration-500"
              />
            </div>
          </div>

          <!-- 左右箭头（悬停显示） -->
          <button
            v-if="project.images.length > 1"
            class="
              absolute left-3 top-1/2 -translate-y-1/2
              w-10 h-10 rounded-full bg-white/80 backdrop-blur-sm
              shadow-md border border-sky-200/50
              flex items-center justify-center
              opacity-0 group-hover:opacity-100
              hover:bg-sky-50 hover:shadow-lg hover:border-sky-300/60
              transition-all duration-200 cursor-pointer z-20
            "
            @click="prev"
          >
            <svg class="w-5 h-5 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <button
            v-if="project.images.length > 1"
            class="
              absolute right-3 top-1/2 -translate-y-1/2
              w-10 h-10 rounded-full bg-white/80 backdrop-blur-sm
              shadow-md border border-sky-200/50
              flex items-center justify-center
              opacity-0 group-hover:opacity-100
              hover:bg-sky-50 hover:shadow-lg hover:border-sky-300/60
              transition-all duration-200 cursor-pointer z-20
            "
            @click="next"
          >
            <svg class="w-5 h-5 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>

          <!-- 页码角标 -->
          <span
            v-if="project.images.length > 1"
            class="absolute bottom-3 right-3 px-2.5 py-1 rounded-full bg-white/80 text-slate-600 text-xs font-medium backdrop-blur-sm border border-sky-200/40 z-10"
          >
            {{ currentIndex + 1 }} / {{ project.images.length }}
          </span>
        </div>

        <!-- 操作按钮 -->
        <div class="flex items-center justify-center gap-3 mt-4 flex-wrap">
          <button
            class="
              inline-flex items-center gap-2 px-5 py-2.5
              rounded-xl bg-white border border-sky-200/60 text-slate-700 text-sm font-medium
              shadow-[0_1px_4px_rgba(0,0,0,0.02),0_4px_12px_rgba(0,0,0,0.04)]
              hover:bg-sky-50 hover:border-sky-300 hover:shadow-md
              active:scale-95 transition-all duration-150 cursor-pointer
            "
            @click="scrollTo('contributions')"
          >
            <svg class="w-4 h-4 text-sky-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            查看我的贡献
          </button>
          <button
            v-if="project.githubUrl"
            class="
              inline-flex items-center gap-2 px-5 py-2.5
              rounded-xl bg-white border border-sky-200/60 text-slate-600 text-sm font-medium
              shadow-[0_1px_4px_rgba(0,0,0,0.02),0_4px_12px_rgba(0,0,0,0.04)]
              hover:bg-sky-50 hover:border-sky-300 hover:shadow-md
              active:scale-95 transition-all duration-150 cursor-pointer
            "
            @click="openGithub"
          >
            <svg class="w-4 h-4 text-slate-500" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
            </svg>
            GitHub 仓库
          </button>
          <button
            v-if="project.demoVideo"
            class="
              inline-flex items-center gap-2 px-5 py-2.5
              rounded-xl bg-white border border-sky-200/60 text-sky-600 text-sm font-medium
              shadow-[0_1px_4px_rgba(0,0,0,0.02),0_4px_12px_rgba(0,0,0,0.04)]
              hover:bg-sky-50 hover:border-sky-300 hover:shadow-md
              active:scale-95 transition-all duration-150 cursor-pointer
            "
            @click="playVideo"
          >
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
              <path stroke-linecap="round" stroke-linejoin="round" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            播放演示视频
          </button>
        </div>

        <!-- 缩略图导航条 -->
        <div v-if="project.images.length > 1" class="flex gap-2 mt-4 overflow-x-auto pb-1 justify-center">
          <button
            v-for="(image, i) in project.images"
            :key="i"
            class="
              flex-shrink-0 rounded-lg overflow-hidden border-2
              transition-all duration-200 cursor-pointer
            "
            :class="currentIndex === i ? 'border-sky-500 shadow-md opacity-100 scale-105' : 'border-transparent opacity-50 hover:opacity-80'"
            @click="goToImg(i)"
          >
            <img
              :src="image"
              :alt="`缩略图 ${i + 1}`"
              class="w-16 h-12 object-cover"
              loading="lazy"
            />
          </button>
        </div>
      </div>

      <!-- ========== 演示视频 ========== -->
      <div v-if="project.demoVideo" id="demo-video" class="mb-10" :class="{ 'scroll-mt-20': videoVisible }">
        <transition name="video-fade">
          <div v-if="videoVisible">
            <h2 class="text-lg font-semibold text-slate-800 mb-3">🎬 演示视频</h2>
            <div class="aspect-video rounded-xl overflow-hidden border border-sky-200/50 bg-gradient-to-b from-white/90 to-white/70 shadow-[0_2px_8px_rgba(0,0,0,0.04),0_8px_24px_rgba(0,0,0,0.06)]">
              <iframe
                :src="project.demoVideo"
                class="w-full h-full"
                allowfullscreen
                loading="lazy"
              />
            </div>
          </div>
        </transition>
      </div>

      <!-- ========== 项目介绍 ========== -->
      <section class="mb-10">
        <h2 class="text-lg font-semibold text-slate-800 mb-3">项目介绍</h2>
        <div class="text-slate-600 leading-relaxed whitespace-pre-line">
          {{ project.description }}
        </div>
      </section>

      <!-- ========== 我的贡献 ========== -->
      <section id="contributions" class="mb-10 scroll-mt-20">
        <h2 class="text-lg font-semibold text-slate-800 mb-3">我的贡献</h2>
        <ul class="space-y-2">
          <li
            v-for="(item, i) in project.contributions"
            :key="i"
            class="flex items-start gap-2.5 text-slate-600"
          >
            <span class="mt-0.5 w-1.5 h-1.5 rounded-full bg-sky-500 flex-shrink-0" />
            {{ item }}
          </li>
        </ul>
      </section>

      <!-- 底部链接 -->
      <section class="flex flex-wrap gap-3 pt-6 border-t border-sky-200/40">
        <a
          :href="project.githubUrl"
          target="_blank"
          class="
            inline-flex items-center gap-2 px-5 py-2.5
            rounded-lg bg-white border border-sky-200/60 text-slate-700 text-sm font-medium
            shadow-[0_1px_4px_rgba(0,0,0,0.02),0_4px_12px_rgba(0,0,0,0.04)]
            hover:bg-sky-50 hover:border-sky-300 hover:shadow-md
            transition-all duration-150
          "
        >
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
          </svg>
          GitHub 仓库
        </a>
        <a
          v-if="project.demoUrl"
          :href="project.demoUrl"
          target="_blank"
          class="
            inline-flex items-center gap-2 px-5 py-2.5
            rounded-lg border border-sky-200/60 text-slate-600 text-sm font-medium
            hover:bg-sky-50 hover:border-sky-300
            transition-all duration-150
          "
        >
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
          </svg>
          在线 Demo
        </a>
      </section>
    </div>
  </main>

  <!-- 404 -->
  <main v-else class="min-h-screen flex flex-col items-center justify-center gap-4 bg-gradient-to-b from-sky-50 to-blue-50">
    <p class="text-slate-400 text-lg">项目未找到</p>
    <button
      class="text-sky-500 hover:text-sky-600 underline underline-offset-2 cursor-pointer transition-colors"
      @click="goBack"
    >
      返回首页
    </button>
  </main>
</template>

<style scoped>
.video-fade-enter-active {
  transition: opacity 0.4s ease, transform 0.4s ease;
}
.video-fade-enter-from {
  opacity: 0;
  transform: translateY(20px);
}
</style>
