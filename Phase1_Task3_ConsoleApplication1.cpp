#include "stdafx.h"
#include "stdio.h"
#include "conio.h"
#include <dirent.h>

extern "C"
{
#include <libavutil/motion_vector.h>
#include <libavformat/avformat.h>
# pragma comment (lib, "avformat.lib")
}
static AVFormatContext *fmt_ctx = NULL;
static AVCodecContext *video_dec_ctx = NULL;
static AVStream *video_stream = NULL;
static const char *src_filename = NULL;
static const char *src_filenameformat = NULL;
static const char *outputf = NULL;
static int aflag = 0;
static int count = 0;

static int video_stream_idx = -1;
static AVFrame *frame = NULL;
static AVFrame *newframe = NULL;
static AVPacket pkt;
static int video_frame_count = 0;
static int r = 1;//Naren

static int decode_packet(int *got_frame, int cached)
{
	int decoded = pkt.size;
	
	*got_frame = 0;
	FILE *fp;
	if (pkt.stream_index == video_stream_idx) {
		int ret = avcodec_decode_video2(video_dec_ctx, frame, got_frame, &pkt);
		if (ret < 0) {
			//TODO : Fix the below line
			//fprintf(stderr, "Error decoding video frame (%s)\n", av_err2str(ret));
			return ret;
		}

		if (*got_frame) {
			int i;
			AVFrameSideData *sd;

			video_frame_count++;
			sd = av_frame_get_side_data(frame, AV_FRAME_DATA_MOTION_VECTORS);
			if (sd) {
				int wrow = frame->width;
				int hcol = frame->height;
				int cellrow = abs(wrow / r);
				int cellcol = abs(hcol / r);
			
				const AVMotionVector *mvs = (const AVMotionVector *)sd->data;
				for (i = 0; i < sd->size / sizeof(*mvs); i++) {

					const AVMotionVector *mv = &mvs[i];



					int ex = mv->dst_x;
					int ey = mv->dst_y;

				
				for (int riter = cellrow; riter <= wrow; riter += cellrow)
				{
					for(int citer = cellcol; citer <= hcol;citer += cellcol)
					{ 
							if (((ex > (riter - cellrow)) && ex <= riter) && ((ey > (citer - cellcol)) && ey <= citer)) {


								count++;
									fp = fopen(outputf, "a");
									fprintf(fp, "<%s; %d ; (%d %d); %d, %d, %d, %d, %d, %d, %d, %d>\n",
										src_filenameformat,video_frame_count, (riter / cellrow) - 1, (citer / cellcol) - 1, mv->source,
										mv->w, mv->h, mv->src_x, mv->src_y,
										mv->dst_x, mv->dst_y, mv->flags);
									fclose(fp);
							}
								
							
						}
//vectors going out of scope
					if(((ex > (riter - cellrow)) && ex <= riter) && (ey > hcol)){
						count++;
						fp = fopen(outputf, "a");
						fprintf(fp, "<%s; %d ; (%d %d); %d, %d, %d, %d, %d, %d, %d, %d>\n",
							src_filenameformat, video_frame_count, (riter / cellrow) - 1, r - 1, mv->source,
							mv->w, mv->h, mv->src_x, mv->src_y,
							mv->dst_x, mv->dst_y, mv->flags);
						fclose(fp);
					
					
					
					
						}
					}
				}
			}
		}
	}

	return decoded;
}
static int open_codec_context(int *stream_idx,
	AVFormatContext *fmt_ctx, enum AVMediaType type)
{
	int ret;
	AVStream *st;
	AVCodecContext *dec_ctx = NULL;
	AVCodec *dec = NULL;
	AVDictionary *opts = NULL;

	ret = av_find_best_stream(fmt_ctx, type, -1, -1, NULL, 0);
	if (ret < 0) {
		fprintf(stderr, "Could not find %s stream in input file '%s'\n",
			av_get_media_type_string(type), src_filename);
		return ret;
	}
	else {
		*stream_idx = ret;
		st = fmt_ctx->streams[*stream_idx];

		/* find decoder for the stream */
		dec_ctx = st->codec;
		dec = avcodec_find_decoder(dec_ctx->codec_id);
		if (!dec) {
			fprintf(stderr, "Failed to find %s codec\n",
				av_get_media_type_string(type));
			return AVERROR(EINVAL);
		}

		/* Init the video decoder */
		av_dict_set(&opts, "flags2", "+export_mvs", 0);
		if ((ret = avcodec_open2(dec_ctx, dec, &opts)) < 0) {
			fprintf(stderr, "Failed to open %s codec\n",
				av_get_media_type_string(type));
			return ret;
		}
	}

	return 0;
}

int main(int argc, char **argv)
{
	char outputfile[100];
	
	int resolution;
	
	int ret = 0, got_frame; int flag = 0;

	DIR *d;

	FILE *fp;
	struct dirent *dir;
	char inputdir[100];
	
	printf("Enter the directory containing Videos:");
	gets_s(inputdir);
	
	printf("Enter the resolution:");
	scanf("%d", &resolution);
	fflush(stdin);
	printf("Enter the Output filename:");
	scanf_s("%s", outputfile, sizeof(outputfile));

	printf("%s", outputfile);
	
	outputf = outputfile;
	r = resolution;
	//printf("%d", resolution);
	//printf("%s", inputdir);
	d = opendir(inputdir);
	dir = readdir(d); dir = readdir(d);
	if (d)
	{
		while ((dir = readdir(d)) != NULL)
		{
			count = 0;
			video_frame_count = 0;
			char inputdirfile[100];
			inputdirfile[0] = '\0';
	
			src_filenameformat = dir->d_name;
			src_filename = strcat(inputdirfile, inputdir);
			src_filename = strcat(inputdirfile, "\\");
			src_filename = 	strcat(inputdirfile, dir->d_name);
			
				printf("%s\n", src_filename);

	//			fp = fopen("C:/Naren/Grad courses/MWD CSE515/Projects/Project 1/Task3/newval1r4new.txt", "a");
	//			fprintf(fp, "%s\n",src_filename);
	//			fclose(fp);

	av_register_all();

	if (avformat_open_input(&fmt_ctx, src_filename, NULL, NULL) < 0) {
		fprintf(stderr, "Could not open source file %s\n", src_filename);
		exit(1);
	}

	if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
		fprintf(stderr, "Could not find stream information\n");
		exit(1);
	}

	if (open_codec_context(&video_stream_idx, fmt_ctx, AVMEDIA_TYPE_VIDEO) >= 0) {
		video_stream = fmt_ctx->streams[video_stream_idx];
		video_dec_ctx = video_stream->codec;
	}

	av_dump_format(fmt_ctx, 0, src_filename, 0);

	if (!video_stream) {
		fprintf(stderr, "Could not find video stream in the input, aborting\n");
		ret = 1;
		goto end;
	}

	frame = av_frame_alloc();
	if (!frame) {
		fprintf(stderr, "Could not allocate frame\n");
		ret = AVERROR(ENOMEM);
		goto end;
	}

	printf("<i;j;l;source,blockw,blockh,srcx,srcy,dstx,dsty>\n");

	/* initialize packet, set data to NULL, let the demuxer fill it */
	av_init_packet(&pkt);
	pkt.data = NULL;
	pkt.size = 0;

	/* read frames from the file */
	while (av_read_frame(fmt_ctx, &pkt) >= 0) {
		AVPacket orig_pkt = pkt;
		do {
			ret = decode_packet(&got_frame, 0);
			if (ret < 0)
				break;
			pkt.data += ret;
			pkt.size -= ret;
		} while (pkt.size > 0);
		av_packet_unref(&orig_pkt);
	}

	/* flush cached frames */
	pkt.data = NULL;
	pkt.size = 0;
	do {
		decode_packet(&got_frame, 1);
	} while (got_frame);



	

	
end:
	avcodec_close(video_dec_ctx);
	avformat_close_input(&fmt_ctx);
	av_frame_free(&frame);

//	fp = fopen("C:/Naren/Grad courses/MWD CSE515/Projects/Project 1/Task3/newval1r4new.txt", "a");
//	fprintf(fp, "COUNT: %d\n", count);
//	fclose(fp);
		}
		closedir(d);
	}
}